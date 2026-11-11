#!/usr/bin/env python3
"""Interactive cleanup for projects on Desktop, Docker, and old Downloads."""

import argparse
import curses
import datetime as dt
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import threading
import time
import unicodedata
from dataclasses import dataclass, field, replace


SKIP_DIRS = {".git", "node_modules", ".venv", "venv", "__pycache__", ".pytest_cache",
             ".mypy_cache", ".ruff_cache", ".tox", ".nox", ".next", ".cache",
             "Library", ".Trash", ".local", ".cargo"}
CACHE_DIRS = {"__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache",
              ".tox", ".nox", ".next"}


@dataclass
class Item:
    kind: str
    label: str
    size: str
    detail: str
    default: bool = False
    path: Path = None
    repo: Path = None
    original: tuple = None
    targets: list = None
    bytes_size: int = 0


def run(args, timeout=30):
    return subprocess.run(args, text=True, capture_output=True, timeout=timeout, check=False)


def human(n):
    value = float(n)
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if value < 1024 or unit == "TiB":
            return f"{value:.0f}{unit}" if unit == "B" else f"{value:.1f}{unit}"
        value /= 1024


def parse_size(value):
    match = re.match(r"^\s*([\d.]+)\s*([kKmMgGtT]?i?[bB])\s*$", value)
    if not match:
        return 0
    number, unit = match.groups()
    prefix = unit[0].upper() if len(unit) > 1 else ""
    power = {"": 0, "K": 1, "M": 2, "G": 3, "T": 4}.get(prefix, 0)
    base = 1024 if "i" in unit else 1000
    return int(float(number) * base ** power)


def signature(path):
    stat = path.lstat()
    return stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns


def allocated_size(path):
    stat = path.stat()
    return getattr(stat, "st_blocks", (stat.st_size + 511) // 512) * 512


def dir_size(path):
    total = 0
    for base, dirs, files in os.walk(path, followlinks=False):
        dirs[:] = [d for d in dirs if not (Path(base) / d).is_symlink()]
        for name in files:
            try:
                total += (Path(base) / name).lstat().st_size
            except OSError:
                pass
    return total


def git_dir(path):
    marker = path / ".git"
    return marker.is_dir() or marker.is_file()


def iter_repos(root, stop=None):
    for base, dirs, _ in os.walk(root, followlinks=False):
        if stop is not None and stop.is_set():
            return
        here = Path(base)
        if git_dir(here):
            check = run(["git", "-C", str(here), "rev-parse", "--show-toplevel"])
            if check.returncode == 0 and Path(check.stdout.strip()).resolve() == here.resolve():
                yield here
            # Keep walking: a repository may contain a nested repository/worktree.
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not (here / d).is_symlink()
                   and not (d.startswith("build") and any((here / d / marker).exists()
                           for marker in ("CMakeCache.txt", "CMakeFiles", "build.ninja", "meson-info")))]


def find_repos(root):
    return list(iter_repos(root))


def project_items(repo, on_item=None, stop=None, min_bytes=0):
    groups = {}
    published = set()
    labels = {"venv": "Python venv", "build": "build*", "cache": "Python/Node cache",
              "node_modules": "node_modules", "cargo": "Cargo target"}
    for base, dirs, _ in os.walk(repo, followlinks=False):
        if stop is not None and stop.is_set():
            break
        here = Path(base)
        remaining = []
        for name in dirs:
            if stop is not None and stop.is_set():
                break
            path = here / name
            if path.is_symlink() or name == ".git":
                continue
            if git_dir(path):
                continue
            kind = None
            selected = False
            if name in (".venv", "venv") and (path / "pyvenv.cfg").is_file():
                kind, selected = "venv", True
            elif name.startswith("build") and any((path / marker).exists() for marker in
                    ("CMakeCache.txt", "CMakeFiles", "build.ninja", "meson-info", "compile_commands.json")):
                kind, selected = "build", True
            elif name in CACHE_DIRS:
                kind, selected = "cache", True
            elif name == "node_modules" and (here / "package.json").is_file():
                kind, selected = "node_modules", True
            elif name == "target" and ((path / ".rustc_info.json").exists() or
                                        (path / "debug").is_dir() or (path / "release").is_dir()) and \
                    (here / "Cargo.toml").is_file():
                kind, selected = "cargo", True
            if kind:
                size = dir_size(path)
                if kind not in groups:
                    item = Item(kind, f"{repo} / {labels[kind]} (1 dirs)", human(size),
                                f"{repo} / 1 directories", selected, repo=repo,
                                targets=[(path, signature(path))], bytes_size=size)
                    groups[kind] = item
                else:
                    item = groups[kind]
                    item.targets.append((path, signature(path)))
                    item.bytes_size += size
                    item.size = human(item.bytes_size)
                    item.label = f"{repo} / {labels[kind]} ({len(item.targets)} dirs)"
                    item.detail = f"{repo} / {len(item.targets)} directories"
                if item.bytes_size > min_bytes and kind not in published:
                    published.add(kind)
                    if on_item:
                        on_item(item)
            else:
                remaining.append(name)
        dirs[:] = remaining
    return [item for item in groups.values() if item.bytes_size > min_bytes]


def git_gc_item(repo, seen, min_bytes=0):
    if not git_gc_allowed(repo):
        return None
    common = run(["git", "-C", str(repo), "rev-parse", "--git-common-dir"])
    if common.returncode:
        return None
    git_path = Path(common.stdout.strip())
    if not git_path.is_absolute():
        git_path = repo / git_path
    key = git_path.resolve()
    if key in seen:
        return None
    seen.add(key)
    counts = run(["git", "-C", str(repo), "count-objects", "-v"])
    parts = dict(re.findall(r"^(size|size-pack):\s*(\d+)$", counts.stdout, re.M))
    object_bytes = 1024 * sum(int(x) for x in parts.values())
    if object_bytes <= min_bytes:
        return None
    size = human(object_bytes) if parts else "?"
    return Item("git_gc", str(repo), size, "Git objects (回収可能量ではありません)", True, repo=repo,
                bytes_size=object_bytes)


def git_gc_allowed(repo):
    result = run(["git", "-C", str(repo), "rev-parse", "--show-superproject-working-tree"])
    return result.returncode == 0 and not result.stdout.strip()


def docker_items():
    if not shutil.which("docker"):
        return []
    result = run(["docker", "system", "df", "--format", "{{json .}}"], timeout=15)
    if result.returncode:
        return []
    values = {}
    for line in result.stdout.splitlines():
        try:
            row = json.loads(line)
            values[row["Type"]] = row.get("Reclaimable", "不明")
        except (ValueError, KeyError, TypeError):
            continue
    rows = [
        ("docker_build", "Docker build cache", "Build Cache", True),
        ("docker_containers", "Docker stopped containers", "Containers", False),
        ("docker_images", "Docker unused images", "Images", False),
        ("docker_volumes", "Docker unused volumes (named 含む)", "Local Volumes", False),
        ("docker_networks", "Docker unused networks", None, False),
    ]
    return [Item(kind, label, values.get(key, "—").split(" (")[0] if key else "—",
                 "Docker 全体", default and not values.get(key, "0B").startswith("0B"),
                 bytes_size=parse_size(values.get(key, "0B").split(" (")[0]) if key else 0)
            for kind, label, key, default in rows]


def download_items(folder, min_bytes, older_days):
    if not folder.is_dir():
        return []
    cutoff = time.time() - older_days * 86400
    items = []
    for path in folder.iterdir():
        if path.is_symlink() or not path.is_file():
            continue
        try:
            stat = path.stat()
        except OSError:
            continue
        if stat.st_size >= min_bytes and stat.st_mtime < cutoff:
            date = dt.datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d")
            items.append(Item("download", str(path), human(stat.st_size),
                              f"Downloads / 更新 {date}", path=path, original=signature(path),
                              bytes_size=stat.st_size))
    return items


def collect(root, downloads, min_bytes, older_days, progress=None, min_item_bytes=0):
    repos = find_repos(root) if root.is_dir() else []
    if progress:
        progress(0, len(repos))
    items = docker_items() + download_items(downloads, min_bytes, older_days)
    seen = set()
    for index, repo in enumerate(repos, 1):
        items.extend(project_items(repo, min_bytes=min_item_bytes))
        gc = git_gc_item(repo, seen, min_item_bytes)
        if gc:
            items.append(gc)
        if progress:
            progress(index, len(repos))
    return items, len(repos)


@dataclass
class State:
    min_bytes: int = 0
    min_item_bytes: int = 1024 ** 2
    older_days: int = 30
    items: list = None
    repo_count: int = 0
    scan_done: bool = False
    scan_error: str = ""
    scan_progress: int = 0
    scan_total: int = 0
    scan_repo: str = ""
    scan_stop: threading.Event = field(default_factory=threading.Event)
    folders: list = None
    folder_name: str = ""
    folder_done: bool = False
    folder_errors: int = 0
    folder_generation: int = 0
    running: bool = False
    done: bool = False
    current: str = ""
    completed: int = 0
    failures: int = 0
    last_error: str = ""


def scan_worker(state, root, downloads, min_bytes, older_days):
    try:
        state.items = docker_items() + download_items(downloads, min_bytes, older_days)
        seen = set()
        if root.is_dir():
            for repo in iter_repos(root, state.scan_stop):
                if state.scan_stop.is_set():
                    break
                state.scan_repo = repo.name
                project_items(repo, on_item=state.items.append, stop=state.scan_stop,
                              min_bytes=state.min_item_bytes)
                if state.scan_stop.is_set():
                    break
                gc = git_gc_item(repo, seen, state.min_item_bytes)
                if state.scan_stop.is_set():
                    break
                if gc:
                    state.items.append(gc)
                state.repo_count += 1
                state.scan_progress = state.repo_count
        state.scan_repo = ""
    except Exception as exc:
        state.scan_error = str(exc)
    finally:
        state.scan_done = True


def folder_worker(state, root, downloads, generation=0):
    folders = []
    for parent in (root, downloads):
        if generation != state.folder_generation:
            return
        if not parent.is_dir():
            continue
        state.folder_name = parent.name
        try:
            children = sorted((p for p in parent.iterdir() if p.is_dir() and not p.is_symlink()),
                              key=lambda p: p.name.lower())
        except OSError:
            continue
        total = 0
        for child in children:
            if generation != state.folder_generation:
                return
            state.folder_name = child.name
            try:
                result = run(["du", "-sk", str(child)], timeout=120)
                if result.returncode or not result.stdout:
                    state.folder_errors += 1
                    continue
                size = int(result.stdout.split()[0]) * 1024
            except (ValueError, IndexError, subprocess.TimeoutExpired, OSError):
                state.folder_errors += 1
                continue
            total += size
            if size > state.min_item_bytes:
                folders.append((str(child), size))
                if generation == state.folder_generation:
                    state.folders = folders[:]
        # Include files directly in the parent directory in its total.
        try:
            total += sum(allocated_size(p) for p in parent.iterdir()
                         if p.is_file() and not p.is_symlink())
        except OSError:
            state.folder_errors += 1
        folders.append((str(parent), total))
        if generation == state.folder_generation:
            state.folders = folders[:]
    if generation == state.folder_generation:
        state.folder_name = ""
        state.folder_done = True


def execute_worker(state, chosen, root, downloads):
    state.running = True
    for item in chosen:
        state.current = item.label
        try:
            if not execute(item, root, downloads):
                state.failures += 1
                state.last_error = f"失敗または対象変更: {item.label}"
        except (OSError, subprocess.SubprocessError) as exc:
            state.failures += 1
            state.last_error = f"{item.label}: {exc}"
        state.completed += 1
    state.current = ""
    state.done = True
    state.folder_generation += 1
    state.folders = None
    state.folder_done = False
    state.folder_errors = 0
    threading.Thread(target=folder_worker,
                     args=(state, root, downloads, state.folder_generation), daemon=True).start()


def clip(value, width):
    used = 0
    output = []
    def char_width(char):
        return 0 if unicodedata.combining(char) else (2 if unicodedata.east_asian_width(char) in "WF" else 1)
    for char in value:
        size = char_width(char)
        if used + size > width:
            while output and used + 1 > width:
                used -= char_width(output.pop())
            return "".join(output) + "…"
        output.append(char)
        used += size
    return value


def display_label(item, root, downloads):
    if item.kind == "download" and item.path:
        return f"~/Downloads/{item.path.name}"
    if item.repo:
        try:
            relative = item.repo.relative_to(root)
        except ValueError:
            relative = item.repo
        if item.targets:
            return f"{relative} / {item.kind} ({len(item.targets)} dirs)"
        return str(relative) + (" [submodule]" if "submodule" in item.detail else "")
    return item.label


def tui(stdscr, state, root, downloads, readonly):
    curses.curs_set(0)
    stdscr.keypad(True)
    stdscr.timeout(200)
    palette = [0] * 7
    if curses.has_colors():
        curses.start_color()
        try:
            curses.use_default_colors()
            background = -1
        except curses.error:
            background = curses.COLOR_BLACK
        for index, color in enumerate((curses.COLOR_CYAN, curses.COLOR_GREEN,
                                       curses.COLOR_YELLOW, curses.COLOR_RED,
                                       curses.COLOR_BLUE, curses.COLOR_MAGENTA), 1):
            try:
                curses.init_pair(index, color, background)
                palette[index] = curses.color_pair(index)
            except curses.error:
                pass
    threading.Thread(target=scan_worker, args=(state, root, downloads,
                                              state.min_bytes, state.older_days), daemon=True).start()
    threading.Thread(target=folder_worker, args=(state, root, downloads), daemon=True).start()
    selected = set()
    seen_count = 0
    all_selection = None
    page = 0  # 0: cleanup candidates, 1: folder sizes, 2: candidate details
    pos = offset = folder_pos = folder_offset = detail_pos = detail_index = 0
    query = ""
    confirm = False
    confirm_ids = []
    chosen = []
    while True:
        items = (state.items or [])[:]
        if not confirm and not state.running:
            for i in range(seen_count, len(items)):
                if all_selection is True or (all_selection is None and items[i].default):
                    selected.add(i)
            seen_count = len(items)
        selected_bytes = sum(items[i].bytes_size for i in selected if items[i].kind != "git_gc")
        gc_bytes = sum(items[i].bytes_size for i in selected if items[i].kind == "git_gc")
        visible_ids = [i for i, item in enumerate(items)
                       if query in (item.kind + " " + item.label + " " + item.detail).lower()]
        pos = min(pos, max(0, len(visible_ids) - 1))
        folders = sorted(state.folders or [], key=lambda row: row[1], reverse=True)
        folder_pos = min(folder_pos, max(0, len(folders) - 1))
        disk = shutil.disk_usage(root if root.exists() else Path.home())
        used = disk.total - disk.free
        height, width = stdscr.getmaxyx()
        stdscr.erase()
        if height < 12 or width < 50:
            stdscr.addnstr(0, 0, "Terminal size: at least 50x12 required. q: quit", max(0, width - 1))
            stdscr.refresh()
            if stdscr.getch() == ord("q") and not state.running:
                return 0
            continue
        def line(y, value, style=curses.A_NORMAL):
            try:
                stdscr.addstr(y, 0, clip(value, width - 2), style)
            except curses.error:
                pass

        line(0, " CACHE CLEAN  |  a 全件チェック/解除  |  [候補] Tab [ディスク]  |  i 詳細  |  q 終了", curses.A_BOLD | palette[1])
        line(1, f" Disk: 合計 {human(disk.total)}  使用 {human(used)} ({used / disk.total:.1%})  空き {human(disk.free)}")
        bar_width = max(8, min(32, width - 25))
        filled = round(bar_width * used / disk.total)
        disk_color = palette[4] if used / disk.total >= .9 else (palette[3] if used / disk.total >= .75 else palette[2])
        line(2, " [" + "#" * filled + "-" * (bar_width - filled) + "]  空き " + f"{disk.free / disk.total:.1%}", disk_color)
        totals = {name: size for name, size in state.folders or []}
        root_size = human(totals[str(root)]) if str(root) in totals else ("—" if state.folder_done else "計測中")
        downloads_size = human(totals[str(downloads)]) if str(downloads) in totals else ("—" if state.folder_done else "計測中")
        folder_status = state.folder_name if not state.folder_done else (f"完了 (計測失敗 {state.folder_errors})" if state.folder_errors else "完了")
        line(3, f" Desktop {root_size}  |  Downloads {downloads_size}  |  フォルダ: {folder_status}", palette[5])
        selected_status = f" 選択容量の概算 {human(selected_bytes)}"
        if gc_bytes:
            selected_status += f"  |  Git GC object {human(gc_bytes)} (回収量ではない)"
        line(4, selected_status, curses.A_BOLD | palette[2])
        if state.running or state.done:
            status = f"実行中 {state.completed}/{len(chosen)} 件  失敗 {state.failures} 件" if not state.done else f"完了 {state.completed - state.failures}/{len(chosen)} 件  失敗 {state.failures} 件"
        elif not state.scan_done:
            status = f"探索中… {state.repo_count} repo/worktree / {len(items)} 候補 / {len(selected)} 件チェック済み / {state.scan_repo}"
        elif state.scan_error:
            status = f"探索エラー: {state.scan_error}"
        else:
            status = f"{state.repo_count} repo/worktree  |  {len(selected)}/{len(items)} 件チェック済み  |  検索: {query or 'なし'}"
        line(5, status, curses.A_BOLD | (palette[4] if state.scan_error or state.failures else palette[3] if not state.scan_done else palette[1]))
        line(6, "─" * min(width - 1, 80), palette[1])
        visible = height - 10
        if page == 0:
            if pos < offset:
                offset = pos
            if pos >= offset + visible:
                offset = pos - visible + 1
            line(7, "  選択   種別               サイズ       対象  (Space: チェック / i: 詳細 / /: 検索)", palette[1])
            for row, index in enumerate(range(offset, min(len(visible_ids), offset + visible)), 8):
                i = visible_ids[index]
                item = items[i]
                label = f"[{'x' if i in selected else ' '}] {item.kind:18} {item.size:>10}  {display_label(item, root, downloads)}"
                item_color = palette[2] if i in selected else (palette[4] if item.kind in ("docker_volumes", "download") else 0)
                line(row, label, item_color | (curses.A_REVERSE if index == pos and not state.running else 0))
            if not visible_ids and not state.scan_done:
                line(8, "候補を探索中… 追加された項目はここに表示されます。", palette[3])
            elif not visible_ids:
                line(8, "表示する候補がありません。検索を解除するには / を押して空欄で Enter。")
            elif not state.running and not state.done:
                line(height - 2, items[visible_ids[pos]].detail)
        elif page == 1:
            if folder_pos < folder_offset:
                folder_offset = folder_pos
            if folder_pos >= folder_offset + visible:
                folder_offset = folder_pos - visible + 1
            line(7, "  フォルダ                       使用量       ディスク比率  (↑↓: 移動)", palette[1])
            for row, index in enumerate(range(folder_offset, min(len(folders), folder_offset + visible)), 8):
                name, size = folders[index]
                display = "~" + name[len(str(Path.home())):] if name.startswith(str(Path.home())) else name
                if name in (str(root), str(downloads)):
                    display += " (合計)"
                line(row, f"{human(size):>11}  {size / disk.total:>7.2%}  {display}",
                     palette[5] | (curses.A_REVERSE if index == folder_pos else 0))
            if not folders:
                line(8, "フォルダがありません" if state.folder_done else "フォルダ使用量を計測中…", palette[3])
            elif folders:
                line(height - 2, folders[folder_pos][0])
        else:
            item = items[detail_index]
            paths = [str(path) for path, _ in item.targets] if item.targets else []
            if item.kind in DOCKER_COMMANDS:
                paths = ["実行コマンド: " + " ".join(DOCKER_COMMANDS[item.kind]),
                         "Docker 全体の未使用リソースが対象です"]
            elif item.kind == "git_gc":
                paths = ["実行コマンド: git -C <repo> gc", str(item.repo),
                         "作業ファイルや submodule 自体は削除しません",
                         "参照されない古い Git object は回収対象です"]
            elif item.kind == "download":
                paths = [str(item.path), item.detail]
            line(7, f" [{'x' if detail_index in selected else ' '}] {item.kind}  {item.size}  {display_label(item, root, downloads)}", palette[1])
            for row, index in enumerate(range(detail_pos, min(len(paths), detail_pos + visible)), 8):
                line(row, f" {index + 1:>3}. {paths[index]}")
            line(height - 2, f"{len(paths)} 件の対象  |  Space: チェック切替 / ↑↓: スクロール / ←: 戻る")
        if state.running:
            line(height - 1, " 実行中: " + state.current, curses.A_BOLD | palette[3])
        elif state.done:
            line(height - 1, " " + (state.last_error or "処理が完了しました") + "  |  Enter / q で終了", curses.A_BOLD | (palette[4] if state.failures else palette[2]))
        elif confirm:
            line(height - 1, f" {len(confirm_ids)} 件を実行します。探索中なら残りを停止します。 [ y: 実行 ] [ Esc: 戻る ]", curses.A_BOLD | palette[4])
        elif readonly:
            line(height - 1, " 閲覧モード  [ Tab: 画面切替 ] [ q: 終了 ]", curses.A_BOLD | palette[1])
        elif page == 2:
            line(height - 1, " [ ← / Esc: 候補へ戻る ] [ Space: チェック切替 ] [ Enter: 実行へ ]", curses.A_BOLD | palette[6])
        else:
            line(height - 1, " [ Enter: チェックした項目を実行へ ] [ Tab: ディスク ] [ q: 終了 ]", curses.A_BOLD | palette[6])
        stdscr.refresh()
        key = stdscr.getch()
        if key == -1:
            continue
        if state.done:
            if key in (ord("q"), 10, 13, curses.KEY_ENTER):
                return 1 if state.failures else 0
            continue
        if state.running:
            continue
        if confirm:
            if key == ord("y"):
                state.scan_stop.set()
                chosen = [replace(items[i], targets=list(items[i].targets) if items[i].targets else None)
                          for i in confirm_ids]
                state.running = True
                threading.Thread(target=execute_worker,
                                 args=(state, chosen, root, downloads), daemon=True).start()
            confirm = False
            continue
        if key in (ord("q"), 27):
            if key == 27 and page == 2:
                page = 0
                continue
            state.scan_stop.set()
            return 0
        if key == 9:
            page = 0 if page in (1, 2) else 1
            continue
        if page == 2 and key in (curses.KEY_LEFT, curses.KEY_BACKSPACE, 127, ord("h")):
            page = 0
            continue
        if page == 0 and key in (ord("i"), curses.KEY_RIGHT) and visible_ids:
            detail_index = visible_ids[pos]
            detail_pos = 0
            page = 2
            continue
        if key in (curses.KEY_UP, ord("k")):
            if page == 0:
                pos = max(0, pos - 1)
            elif page == 1:
                folder_pos = max(0, folder_pos - 1)
            else:
                detail_pos = max(0, detail_pos - 1)
        elif key in (curses.KEY_DOWN, ord("j")):
            if page == 0:
                pos = min(len(visible_ids) - 1, pos + 1) if visible_ids else 0
            elif page == 1:
                folder_pos = min(len(folders) - 1, folder_pos + 1) if folders else 0
            else:
                detail_pos = min(max(0, len(paths) - visible), detail_pos + 1)
        elif key == ord("/") and page == 0:
            line(height - 2, "検索 (空欄で解除): ")
            curses.echo()
            curses.curs_set(1)
            stdscr.timeout(-1)
            try:
                raw = stdscr.getstr(height - 2, min(22, width - 1), max(1, width - 24))
                query = raw.decode("utf-8", "replace").lower()
            finally:
                stdscr.timeout(200)
                curses.noecho()
                curses.curs_set(0)
            pos = offset = 0
        elif key == ord(" ") and page == 0 and visible_ids:
            i = visible_ids[pos]
            if i in selected:
                selected.remove(i)
            else:
                selected.add(i)
        elif key == ord(" ") and page == 2:
            if detail_index in selected:
                selected.remove(detail_index)
            else:
                selected.add(detail_index)
        elif key in (ord("a"), ord("A")) and page == 0:
            all_selection = not items or len(selected) != len(items)
            if all_selection:
                selected.update(range(len(items)))
            else:
                selected.clear()
        elif key == ord("n") and page == 0:
            selected.difference_update(visible_ids)
        elif key in (10, 13, curses.KEY_ENTER) and selected and not readonly:
            confirm_ids = sorted(selected)
            confirm = True


DOCKER_COMMANDS = {
    "docker_build": ["docker", "builder", "prune", "-a", "-f"],
    "docker_images": ["docker", "image", "prune", "-a", "-f"],
    "docker_containers": ["docker", "container", "prune", "-f"],
    "docker_volumes": ["docker", "volume", "prune", "-a", "-f"],
    "docker_networks": ["docker", "network", "prune", "-f"],
}


def execute(item, root, downloads):
    if item.kind in DOCKER_COMMANDS:
        return subprocess.run(DOCKER_COMMANDS[item.kind], capture_output=True, check=False).returncode == 0
    if item.kind == "git_gc":
        if not item.repo or not git_gc_allowed(item.repo):
            return False
        return subprocess.run(["git", "-C", str(item.repo), "gc"], capture_output=True, check=False).returncode == 0
    if item.targets:
        if not item.repo or not git_dir(item.repo):
            return False
        repo_path = str(item.repo.resolve())
        for path, original in item.targets:
            if path.is_symlink() or not path.is_dir() or signature(path) != original:
                return False
            if os.path.commonpath((str(path.resolve()), repo_path)) != repo_path:
                return False
        for path, _ in item.targets:
            shutil.rmtree(path)
        return True
    path = item.path
    if not path or path.is_symlink() or signature(path) != item.original:
        return False
    if item.kind == "download":
        if path.parent.resolve() != downloads.resolve() or not path.is_file():
            return False
        path.unlink()
    else:
        if not path.is_dir() or not item.repo or not git_dir(item.repo):
            return False
        if os.path.commonpath((str(path.resolve()), str(item.repo.resolve()))) != str(item.repo.resolve()) or path == item.repo:
            return False
        shutil.rmtree(path)
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.home() / "Desktop",
                        help="Git repo を探す場所 (既定: ~/Desktop)")
    parser.add_argument("--downloads", type=Path, default=Path.home() / "Downloads")
    parser.add_argument("--min-mib", type=int, default=500, help="Downloads の最小サイズ MiB")
    parser.add_argument("--min-item-mib", type=int, default=1,
                        help="repo の候補として表示する最小サイズ MiB (既定: 1、0 で小さい候補も表示)")
    parser.add_argument("--older-days", type=int, default=30, help="Downloads の最小経過日数")
    parser.add_argument("--list", action="store_true", help="TUI で閲覧のみ")
    args = parser.parse_args()
    if args.min_mib < 0 or args.min_item_mib < 0 or args.older_days < 0:
        parser.error("閾値は 0 以上にしてください")
    root, downloads = args.root.expanduser().resolve(), args.downloads.expanduser().resolve()
    if not (sys.stdin.isatty() and sys.stdout.isatty()):
        parser.error("対話ターミナルで実行してください")
    state = State()
    state.min_bytes = args.min_mib * 1024 ** 2
    state.min_item_bytes = args.min_item_mib * 1024 ** 2
    state.older_days = args.older_days
    sys.exit(curses.wrapper(tui, state, root, downloads, args.list))


if __name__ == "__main__":
    main()
