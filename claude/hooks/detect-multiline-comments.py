#!/usr/bin/env python3
"""CLAUDE.md「Max 1 line per comment」違反 (連続コメント・3行以上の docstring/doc コメント) を検知し修正を促す PostToolUse hook。"""

import ast
import fnmatch
import json
import os
import re
import subprocess
import sys

_MARKER_RULES = [
    (
        (
            "*.sh",
            "*.bash",
            "*.zsh",
            "*.py",
            "*.rb",
            "*.pl",
            "*.nix",
            "*.toml",
            "*.yml",
            "*.yaml",
            "*.conf",
            "*.tf",
            "*.fish",
            "*.mk",
            "Makefile",
        ),
        "#",
    ),
    (
        (
            "*.c",
            "*.h",
            "*.cpp",
            "*.hpp",
            "*.cc",
            "*.cs",
            "*.m",
            "*.mm",
            "*.swift",
            "*.js",
            "*.jsx",
            "*.ts",
            "*.tsx",
            "*.go",
            "*.rs",
            "*.java",
            "*.kt",
            "*.kts",
            "*.scala",
            "*.dart",
            "*.zig",
        ),
        "//",
    ),
    (("*.lua", "*.hs", "*.sql", "*.elm"), "--"),
    (("*.vim", "*vimrc"), '"'),
    (("*.el", "*.lisp", "*.clj"), ";"),
]

_DOCSTRING_PATTERN = re.compile(r'("""|\'\'\')(.*?)\1', re.DOTALL)
_AT_STRIP_PATTERN = re.compile(r'^[-!/*#";]*[ \t]*')


def marker_for(path: str) -> str:
    """拡張子/ファイル名からコメント記号を決める (該当なしは空文字)。"""
    for patterns, marker in _MARKER_RULES:
        if any(fnmatch.fnmatch(path, p) for p in patterns):
            return marker
    return ""


def extract_prefix_blocks(text: str, marker: str, threshold: int, exclude_marker: str = "", filt: bool = False) -> list:
    """marker 前置行が threshold 行以上連続するブロックを抽出する (exclude_marker 前置行は除外、filt=True で shebang 除外/@行透過)。"""
    blocks: list = []
    buf: list = []

    def flush() -> None:
        nonlocal buf
        if len(buf) >= threshold:
            blocks.append("\n".join(buf))
        buf = []

    for line in text.split("\n"):
        stripped = line.lstrip(" \t")
        if stripped.startswith(marker) and (not exclude_marker or not stripped.startswith(exclude_marker)):
            if filt and stripped.startswith("#!"):
                flush()
                continue
            if filt:
                rest = _AT_STRIP_PATTERN.sub("", stripped[len(marker) :])
                if rest.startswith("@"):
                    continue
            buf.append(line)
        else:
            flush()
    flush()
    return blocks


def extract_docstring_blocks(text: str, threshold: int) -> list:
    """docstring を threshold 行以上のもののみ抽出する。構文的に妥当なら ast で正確に判定し (正規表現は文字列リテラル中の三重引用符と誤認しうる)、Edit の断片等で構文解析できない場合のみ正規表現にフォールバックする。"""
    try:
        tree = ast.parse(text)
    except (SyntaxError, ValueError):
        return [b for b in (m.group(0) for m in _DOCSTRING_PATTERN.finditer(text)) if b.count("\n") + 1 >= threshold]

    lines = text.split("\n")
    blocks = []
    candidates = [tree, *(n for n in ast.walk(tree) if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)))]
    for node in candidates:
        src = _docstring_source(lines, node)
        if src is not None and src.count("\n") + 1 >= threshold:
            blocks.append(src)
    return blocks


def _docstring_source(lines: list, node: ast.AST):
    """node の docstring 部分に対応する生ソース片を返す (docstring でなければ None)。"""
    body = getattr(node, "body", None)
    if not body:
        return None
    first = body[0]
    if not (isinstance(first, ast.Expr) and isinstance(first.value, ast.Constant) and isinstance(first.value.value, str)):
        return None
    v = first.value
    if v.lineno == v.end_lineno:
        return lines[v.lineno - 1][v.col_offset : v.end_col_offset]
    parts = [lines[v.lineno - 1][v.col_offset :], *lines[v.lineno : v.end_lineno - 1], lines[v.end_lineno - 1][: v.end_col_offset]]
    return "\n".join(parts)


def diff_new_blocks(new_blocks: list, old_raw: str, old_blocks: list) -> list:
    """old に存在しない新規ブロックのみ返す (@行混在時は old_blocks 側とも比較し非連続化に対応)。"""
    return [b for b in new_blocks if b not in old_raw and not any(b in ob for ob in old_blocks)]


def resolve_head_content(path: str) -> str:
    """Write (old_string なし) 用に git HEAD の内容を取得する (呼び出し元で repo root に cd 済み前提)。"""
    try:
        rel = (
            subprocess.run(["git", "ls-files", "--full-name", "--", path], capture_output=True, text=True, check=False)
            .stdout.split("\n")[0]
            .strip()
        )
        if not rel:
            return ""
        return subprocess.run(["git", "show", f"HEAD:{rel}"], capture_output=True, text=True, check=False).stdout
    except OSError:
        return ""


_COMMENT_GUIDANCE = """CLAUDE.md の Comments ルール違反の可能性: {path} に複数行コメントブロックが追加された。
以下のワークフローを今回の Edit 1 回で完結させる (段階的な削減はしない):

1. コメントが WHY (非自明な理由: workaround・制約・ドメイン知識) / Why not (採らなかった選択肢とその理由) を述べているか確認する
2. 述べていない → 削除する
   - what コメント (次の行が何をするかの言い換え) — What の説明はテストコードの責務
   - Usage・列挙
   - 変更過程の説明 (fixed / changed 等)
3. 述べている → 1 行に削減する
   - 要約不能な複雑な制約/ドメイン知識のみ、そのまま残して再編集しない

事実として正しい既存コメントは保持する。

## 検出ブロック (コメント)
{blocks}
"""

_DOCSTRING_GUIDANCE = """{path} に 3 行以上の docstring ブロックが追加された。
Google スタイルの Args / Returns / Raises 等、構造上必要な記述は保持してよいが以下を確認する:

1. 1 行目のサマリと重複する WHAT の言い換えが後続行にないか
2. 関数名・引数名から自明な説明を書いていないか
3. 不要なら削除し、Args/Returns 等の必要なセクションのみ残す

## 検出ブロック (docstring)
{blocks}
"""

_DOC_COMMENT_GUIDANCE = """{path} に 3 行以上の /// doc コメントブロックが追加された。
C# の XML タグ (<summary>/<param>/<returns> 等) や Rust の doc セクション (# Arguments/# Examples 等)、構造上必要な記述は保持してよいが以下を確認する:

1. 1 行目のサマリと重複する WHAT の言い換えが後続行にないか
2. 関数名・引数名から自明な説明を書いていないか
3. 不要なら削除し、構造上必要なセクションのみ残す

## 検出ブロック (doc コメント)
{blocks}
"""


def format_blocks(blocks: list) -> str:
    """検出ブロックを表示用テキストに整形する。"""
    return "".join(f"{b}\n----\n" for b in blocks)


def main() -> int:
    try:
        payload = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        return 0

    if payload.get("stop_hook_active"):
        return 0

    tool_input = payload.get("tool_input", {})
    new = tool_input.get("new_string") or tool_input.get("content") or ""
    if not new:
        return 0
    old = tool_input.get("old_string") or ""
    path = tool_input.get("file_path") or ""

    marker = marker_for(path)
    is_py = fnmatch.fnmatch(path, "*.py")
    if not marker and not is_py:
        return 0

    doc_marker = "///" if marker == "//" else ""

    if not old and os.path.isfile(path):
        old = resolve_head_content(path)

    sections = []

    if marker:
        new_blocks = extract_prefix_blocks(new, marker, 2, doc_marker, filt=True)
        if new_blocks:
            old_blocks = extract_prefix_blocks(old, marker, 2, doc_marker, filt=True)
            found = diff_new_blocks(new_blocks, old, old_blocks)
            if found:
                sections.append(_COMMENT_GUIDANCE.format(path=path, blocks=format_blocks(found)))

    if doc_marker:
        new_blocks = extract_prefix_blocks(new, doc_marker, 3)
        if new_blocks:
            old_blocks = extract_prefix_blocks(old, doc_marker, 3)
            found = diff_new_blocks(new_blocks, old, old_blocks)
            if found:
                sections.append(_DOC_COMMENT_GUIDANCE.format(path=path, blocks=format_blocks(found)))

    if is_py:
        new_blocks = extract_docstring_blocks(new, 3)
        if new_blocks:
            old_blocks = extract_docstring_blocks(old, 3)
            found = diff_new_blocks(new_blocks, old, old_blocks)
            if found:
                sections.append(_DOCSTRING_GUIDANCE.format(path=path, blocks=format_blocks(found)))

    if not sections:
        return 0

    sys.stderr.write("\n".join(sections))
    return 2


if __name__ == "__main__":
    sys.exit(main())
