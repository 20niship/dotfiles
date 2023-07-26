" https://note.com/histone/n/na8ebb8a5909f のプラグインより
" フォントのインストールは --> mkdir -p ~/.local/share/fonts; cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

set guifont=DroidSansMono\ Nerd\ Font\ 13
set guifontwide=DroidSansMono\ Nerd\ Font\ 13
set hlsearch
set laststatus=2
set ruler
set history=1000
set number "行頭に数字を表示する
set cursorline        "current lineをマークアップ           
set hls               "検索文字のハイライト　               
set expandtab         "タブ入力を空白に置き換える         
set smartindent       "改行時に入力された行末に合わせて、次の行のインデントを調整する    
set linebreak         "word wrapping                                                     
set clipboard=unnamed "nvimのyankとmacのクリップボードを共有する
set title "タイトルにパスを表示する
set vb t_vb= "ベルをオフにするこれを使用すると、いちいちビープ音が鳴らない

"インデント関係
set expandtab "空白をタブとして認識しないようにする
set tabstop=2 "一個のタブを空白何個分にとるか
set shiftwidth=2      "自動インデント幅                     
set softtabstop=2 "tabを押した時に空白何個分のインデントをとるか決めます。
set autoindent "改行したりした時にインデントを保持してくれます。

"検索関係
set incsearch "文字検索時にリアルタイムで検索してくれます。
set smartcase "大文字小文字を区別せずに検索してくれます。
set hlsearch "検索したもじがハイライトされます。
set mouse=a "マウスでカーソルの位置を指定できる
set ignorecase smartcase 

"その他
set autoread "編集中に別のところで編集されたら自動で読み込みます。
set showcmd "入力中のコマンドを表示します。右下に表示されます。
set whichwrap=b,s,h,l,<,>,[,] "行末、行頭で行を跨ぐことができるようになります。
"set colorcolumn=80 "80文字目にラインを入れる
set scrolloff=5 " SCROLL
set autoread " 更新時自動再読込み
set hidden " 編集中でも他のファイルを開けるようにする

" Swap and backup files 
" set backup    "バックアップファイルを生成する
set nobackup  "バックアップファイルを生成しない（デフォルト）
set backupdir=.,~/tmp,~/    "デフォルトの設定（カレントディレクトリに作られる）

set swapfile    "スワップファイルを生成する（デフォルト）
" set noswapfile  "スワップファイルを生成しない
set directory=.    "デフォルトの設定（カレントディレクトリに作成）
set updatetime=30000  "30秒ごとにswapファイルを保存
set updatecount=500   "500文字タイプするごとに保存


" matchpairs
set matchpairs& matchpairs+=<:>

" command mode
set wildmenu wildmode=longest:full,full

" 折りたたみ
" set foldenable
" set foldcolumn=1 " 左側に折りたたみガイド表示
" set foldmethod=indent " 折畳の判別
set foldmethod=syntax "foldを使用する           
" set foldtext=Mopp_fold() " 折りたたみ時の表示設定
" set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo " fold内に移動すれば自動で開く
set nofoldenable    " ファイルを開いたときには折りたたみを展開して表示 

set laststatus=2      " 下のステータスライン
set noshowmode        " デフォルトのステータスラインを消す
set showtabline=2
set statusline=2      " ステータスラインの記述

" Esc SETTINGS
" inoremap jk <Esc>
inoremap jj <Esc>


tnoremap <Esc> <C-\><C-n> " terminalからESCで抜けられるようにする
command! -nargs=* T split | wincmd j | resize 15 | terminal <args>
" VSCodeのように :term でターミナルを開いたときには画面下部に表示する
autocmd TermOpen * startinsert " ターミナルを開いたときはデフォルトでインサートモードにする


set encoding=utf8
syntax enable

let g:vimsyn_embed='lPr' " Luaでシンタックスハイライト


" #################    DEINの設定   ###################
if &compatible
  set nocompatible               " Be iMproved                      
endif

" --------  dein ----------

let $CACHE = expand('~/.cache')
if !isdirectory($CACHE)
  call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
  let s:dein_dir = fnamemodify('dein.vim', ':p')
  if !isdirectory(s:dein_dir)
    let s:dein_dir = $CACHE . '/dein/repos/github.com/Shougo/dein.vim'
    if !isdirectory(s:dein_dir)
      execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    endif
  endif
  execute 'set runtimepath^=' . substitute(
        \ fnamemodify(s:dein_dir, ':p') , '[/\\]$', '', '')
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

packadd! matchit

call dein#begin('~/.cache/dein')                          
  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  call dein#add('github/copilot.vim')

  call dein#add("atusy/tsnode-marker.nvim")

  " COlorschemes 
  " call dein#add('tomasiser/vim-code-dark')
  " call dein#add('Mofiqul/vscode.nvim')
  call dein#add('tomasr/molokai')
  call dein#add('NLKNguyen/papercolor-theme')
  call dein#add('joshdick/onedark.vim')
  call dein#add("EdenEast/nightfox.nvim")
  call dein#add("bluz71/vim-moonfly-colors")
  call dein#add('Everblush/everblush.vim')
  call dein#add('rebelot/kanagawa.nvim')

  " ファイル表示
  " call dein#add('preservim/nerdtree')

  " airline : ステータスバーをかっこよくする
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('ryanoasis/vim-devicons')

  " スタートアップ画面の表示をかっこよくする
  call dein#add('goolord/alpha-nvim')

  " LSP関連
  call dein#add('neovim/nvim-lspconfig')
  call dein#add('williamboman/mason.nvim')
  call dein#add('williamboman/mason-lspconfig.nvim')
  call dein#add('hrsh7th/cmp-nvim-lsp')
  call dein#add('hrsh7th/cmp-buffer')
  call dein#add('hrsh7th/cmp-path')
  call dein#add('hrsh7th/cmp-cmdline')
  call dein#add('hrsh7th/nvim-cmp')
  call dein#add('hrsh7th/cmp-vsnip')
  call dein#add('hrsh7th/vim-vsnip')

  " LSPのエラーを一覧表示
  call dein#add('kyazdani42/nvim-web-devicons')
  call dein#add('folke/trouble.nvim')

  call dein#add('j-hui/fidget.nvim') " LSPのindexしているところをUI表示

  " コメントアウト
  call dein#add('tpope/vim-commentary')

  " インデントに薄く縦線をつける
  call dein#add('Yggdroot/indentLine')

  " その他ファイルのハイライト
  call dein#add('chrisbra/csv.vim')
  call dein#add('plasticboy/vim-markdown')

  " telescope
  call dein#add('nvim-lua/popup.nvim')
  call dein#add('nvim-lua/plenary.nvim')
  call dein#add('nvim-telescope/telescope.nvim')
  call dein#add('nvim-telescope/telescope-media-files.nvim') " 画像ファイルを表示

  " Fern
  call dein#add('lambdalisue/fern.vim')
  call dein#add('lambdalisue/fern-renderer-nerdfont.vim')
  call dein#add('LumaKernel/fern-mapping-fzf.vim')
  call dein#add('lambdalisue/nerdfont.vim')
  call dein#add('lambdalisue/fern-git-status.vim')
  call dein#add('lambdalisue/fern-mapping-git.vim')
  call dein#add('lambdalisue/fern-bookmark.vim')
  call dein#add('lambdalisue/fern-hijack.vim')

  " jupyter notebookを使えるようにする
  " call dein#add('goerz/jupytext.vim')
  
  " ファイルの関数一覧などを左右に表示
  call dein#add('majutsushi/tagbar')

  " HTMLの閉じタグを自動で生成する
  call dein#add('alvan/vim-closetag')

  " Formatter
  " call dein#add('mhartington/formatter.nvim')
  
  " notification
  call dein#add('rcarriga/nvim-notify')
  
  " 閉じカッコの自動補間
  call dein#add('cohama/lexima.vim')

  " clang-formatを使えるように
  call dein#add('rhysd/vim-clang-format')

  " snippet
  call dein#add('SirVer/ultisnips')
  call dein#add('honza/vim-snippets')
  call dein#add('quangnguyen30192/cmp-nvim-ultisnips')

  call dein#add('tpope/vim-surround')
  
  " シンタックスハイライト
  call dein#add('tikhomirov/vim-glsl') " glsl
  call dein#add ('pangloss/vim-javascript')  " React
  call dein#add ('mxw/vim-jsx')
  call dein#add('lervag/vimtex') " latex
  call dein#add('RaafatTurki/hex.nvim') " バイナリファイル
  call dein#add ('pantharshit00/vim-prisma')
  call dein#add('norcalli/nvim-colorizer.lua') " カラーを表示

  " gitいろいろ 
  call dein#add('airblade/vim-gitgutter')
  call dein#add('tpope/vim-fugitive')
  call dein#add('akinsho/git-conflict.nvim')
  call dein#add('lewis6991/gitsigns.nvim')
  call dein#add('NeogitOrg/neogit')
  call dein#add('junegunn/gv.vim')
call dein#end()
filetype plugin indent on         

set termguicolors 

colorscheme kanagawa

" ---------------  airline --------------------------------
let g:airline_powerline_fonts = 1
" let g:airline#extensions#bufferline#enabled = 1
" let g:airline#extensions#denite#enabled = 1
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#default#layout = [[ 'a', 'b', 'c' ], [ 'x', 'y', 'z']]
let g:airline#extensions#fzf#enabled = 1
let g:airline#extensions#fugitiveline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#close_symbol = 'X'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter ='default'
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ' '
let g:airline#extensions#tabline#show_close_button = 1
let g:airline_detect_modified=1
let g:airline_left_alt_sep = ''
let g:airline_left_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_stl_path_style = 'short'
let g:airline_theme = 'simple'

" タブの切り替え
nmap <C-p> <Plug>AirlineSelectPrevTab
nmap <C-n> <Plug>AirlineSelectNextTab

" tagbarの使用
let g:tagbar_width = 30        " 初期設定はwidth=40なのでちょっと幅とりすぎ。
let g:tagbar_autoshowtag = 1   " :TagbarShowTag を叩かなくても有効にする
nmap <F8> :TagbarToggle<CR> 

" 閉じタグを自動で生成するファイル
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.erb,*.php,*.vue,*.ejs'

" filetype plugin on
" let g:netwr_banner = 0
" let g:netrw_liststyle = 3
" let g:netrw_browse_split = 4
" let g:netrw_winsize = 30
" let g:netrw_sizestyle = "H"
" let g:netrw_timefmt = "%Y/%m/%d(%a) %H:%M:%S"
" let g:netrw_preview = 1

"/// SPLIT BORDER SETTINGS
hi VertSplit cterm=none

" ---------------  Indentline --------------------------------
let g:indentLine_color_gui = "#555555"
autocmd FileType tex let g:indentLine_color_gui = "#dddddd"
autocmd BufNewFile,BufRead *.tex hi Statement guifg=#dddddd
" let g:indentLine_char = '┊'
let g:indentLine_char = '│'
let g:indentLine_conceallevel=1
let g:indentLine_concealcursor=""
set conceallevel=1
set concealcursor-=incv
autocmd FileType tex let g:indentLine_enabled=0

" ---------------  Fern  --------------------------------
" lambdalisue/fern.vim settings
autocmd Filetype fern setlocal nonu norelativenumber
function! s:init_fern() abort
  nmap <buffer> n <Plug>(fern-action-new-path)
  nmap <buffer> d <Plug>(fern-action-remove)
  nmap <buffer> m <Plug>(fern-action-move)
endfunction
augroup my-fern
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END

let g:fern#renderer = "nerdfont"

" fzf settings
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,
                  \ 'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }
  
nnoremap <C-h> :Fern . -reveal=% -drawer -toggle -width=40<CR>


" デフォルトのLeaderキー： " \ "  
" spaceに変更
let mapleader = "\<space>"

" ---------------  telescope --------------------------------
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fl <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fg <cmd>Telescope git_files<cr>


" trouble.nvim
nnoremap <F2> <cmd>TroubleToggle<cr>
nnoremap <F5> <cmd>TroubleToggle<cr>
nnoremap <F3> <cmd>TroubleToggle workspace_diagnostics<cr>


" Provided by setup function
" nnoremap <silent> <leader>f :Format<CR>


" notification hilights
highlight NotifyERRORBorder guifg=#8A1F1F
highlight NotifyWARNBorder guifg=#79491D
highlight NotifyINFOBorder guifg=#4F6752
highlight NotifyDEBUGBorder guifg=#8B8B8B
highlight NotifyTRACEBorder guifg=#4F3552
highlight NotifyERRORIcon guifg=#F70067
highlight NotifyWARNIcon guifg=#F79000
highlight NotifyINFOIcon guifg=#A9FF68
highlight NotifyDEBUGIcon guifg=#8B8B8B
highlight NotifyTRACEIcon guifg=#D484FF
highlight NotifyERRORTitle  guifg=#F70067
highlight NotifyWARNTitle guifg=#F79000
highlight NotifyINFOTitle guifg=#A9FF68
highlight NotifyDEBUGTitle  guifg=#8B8B8B
highlight NotifyTRACETitle  guifg=#D484FF
highlight link NotifyERRORBody Normal
highlight link NotifyWARNBody Normal
highlight link NotifyINFOBody Normal
highlight link NotifyDEBUGBody Normal
highlight link NotifyTRACEBody Normal


" ---------------   clang-format   -----------------
" let g:clang_format#style_options = {
"             \ "AccessModifierOffset" : -4,
"             \ "AllowShortIfStatementsOnASingleLine" : "true",
"             \ "AlwaysBreakTemplateDeclarations" : "true",
"             \ "Standard" : "C++11",
"             \ "BreakBeforeBraces" : "Stroustrup"}
" map to <Leader>cf in C++ code
" autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
" autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
" autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
" nmap <Leader>C :ClangFormatAutoToggle<CR>

" let g:lsp_settings = {
" \  'clangd': {'cmd': ['clangd-14.0']},
" \  'efm-langserver': {'disabled': v:false}
" \}


let g:python3_host_prog = "/usr/bin/python3" 
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"

autocmd! BufNewFile,BufRead *.vs,*.fs set ft=glsl

" ---------------   LSPのセッティング

lua << EOF
   require("mason").setup()

   require('hex').setup()

   local nvim_lsp = require('lspconfig')
   local mason_lspconfig = require('mason-lspconfig')
   mason_lspconfig.setup_handlers({ function(server_name)
     local opts = {
        capabilities = require('cmp_nvim_lsp').default_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )
     }
     nvim_lsp[server_name].setup(opts)
     end 
   })


    -- keyboard shortcut
    vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
    vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<CR>')
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
    vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
    vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
    vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')


    -- 補完機能の設定
    vim.opt.completeopt = "menu,menuone,noselect"
    local cmp = require("cmp")
    cmp.setup({
      snippet = {
        expand = function(args)
          -- vim.fn["vsnip#anonymous"](args.body)
          vim.fn["UltiSnips#Anon"](args.body) 
        end,
      },
      mapping = {
        ["<C-j>"] = cmp.mapping.scroll_docs(-4),
        ["<C-k>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "ultisnips" },
      }, {
        { name = "buffer" },
      })
    })
  
   -- LSPのエラー一覧表示（trouble.nvim)
  require("trouble").setup{
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = true, -- use devicons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = {"o"}, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = {"zM", "zm"}, -- close all folds
        open_folds = {"zR", "zr"}, -- open all folds
        toggle_fold = {"zA", "za"}, -- toggle fold of current file
        previous = "k", -- preview item
        next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
    signs = {
        -- icons / text used for a diagnostic
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "﫠"
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
}


--  vim-notify : notification
vim.notify =require("notify");
vim.notify.setup({
--   -- Animation style (see below for details)
  stages = "slide",
  -- Function called when a new window is opened, use for changing win settings/config
  on_open = nil,
  -- Function called when a window is closed
  on_close = nil,
  -- Render function for notifications. See notify-render()
  render = "default",
  -- Default timeout for notifications
  timeout = 1700,
  -- Max number of columns for messages
  max_width = nil,
  -- Max number of lines for a message
  max_height = nil,
  -- For stages that change opacity this is treated as the highlight behind the window
  -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
  background_colour = "Normal",
  -- Minimum width for notification windows
  minimum_width = 50,
  -- Icons for the different levels
  icons = {ERROR = "", WARN = "", INFO = "", DEBUG = "",TRACE = "✎" },
})


-- 画像ファイルをtelescopeでプレビューするための設定
-- https://github.com/nvim-telescope/telescope-media-files.nvim
require('telescope').load_extension('media_files')
require'telescope'.setup {
  extensions = {
    media_files = {
      -- filetypes whitelist
      -- defaults to 
      filetypes = {"png", "jpg", "mp4", "webm", "pdf"},
      -- find command (defaults to `fd`)
      find_cmd = "rg"
    }
  },
}

require'alpha'.setup(require'alpha.themes.startify'.config)
require("fidget").setup {}
require("fidget").setup {}
require('gitsigns').setup()
require('git-conflict').setup()
require('neogit').setup{}

EOF


