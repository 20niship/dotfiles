" colorscheme delek

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
set tabstop   =2      "タブ幅                        
set shiftwidth=2      "自動インデント幅                     
set smartindent       "改行時に入力された行末に合わせて、次の行のインデントを調整する    
set linebreak         "word wrapping                                                     
set clipboard=unnamed "nvimのyankとmacのクリップボードを共有する
set title "タイトルにパスを表示する
set vb t_vb= "ベルをオフにするこれを使用すると、いちいちビープ音が鳴らない

"インデント関係
set expandtab "空白をタブとして認識しないようにする
set tabstop=2 "一個のタブを空白何個分にとるか
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
set noswapfile " スワップファイルを作らない


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
inoremap jk <Esc>
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

" Required:
set runtimepath+=/home/owner/.cache/dein/repos/github.com/Shougo/dein.vim

packadd! matchit

call dein#begin('~/.cache/dein')                          
  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  
  " VSCodeのようなカラースキームにする(カッコが見にくいので却下)
  call dein#add('tomasiser/vim-code-dark')
  call dein#add('Mofiqul/vscode.nvim')
  call dein#add('tomasr/molokai')
  call dein#add('NLKNguyen/papercolor-theme')
  " call dein#add('joshdick/onedark.vim')

  " ファイル表示
  " call dein#add('preservim/nerdtree')

  " airline : ステータスバーをかっこよくする
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('ryanoasis/vim-devicons')

  " LSP関連
  call dein#add('neovim/nvim-lspconfig')
  call dein#add('williamboman/nvim-lsp-installer')
  call dein#add('hrsh7th/cmp-nvim-lsp')
  call dein#add('hrsh7th/cmp-buffer')
  call dein#add('hrsh7th/cmp-path')
  call dein#add('hrsh7th/cmp-cmdline')
  call dein#add('hrsh7th/nvim-cmp')
  call dein#add('hrsh7th/cmp-vsnip')
  call dein#add('hrsh7th/vim-vsnip')
  call dein#add('prabirshrestha/vim-lsp')
  call dein#add('mattn/vim-lsp-settings')

  " LSPのエラーを一覧表示
  call dein#add('kyazdani42/nvim-web-devicons')
  call dein#add('folke/trouble.nvim')

  " Windowのリサイズをやりやすくする
  " マウスでリサイズできるので削除
  " call dein#add('simeji/winresizer')

  " コメントアウト
  call dein#add('tpope/vim-commentary')

  " gitいろいろ 
  call dein#add('airblade/vim-gitgutter')

  " インデントに薄く縦線をつける
  call dein#add('Yggdroot/indentLine')

  " その他ファイルのハイライト
  call dein#add('chrisbra/csv.vim')
  call dein#add('plasticboy/vim-markdown')

  " telescope
  call dein#add('nvim-lua/popup.nvim')
  call dein#add('nvim-lua/plenary.nvim')
  call dein#add('nvim-telescope/telescope.nvim')

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
call dein#end()

filetype plugin indent on         

set termguicolors 
" If you want to install not installed plugins on startup.          
"if dein#check_install()          
"  call dein#install()            
"endif                            


" ################# 各種プラグインの設定 #################
" colorscheme onedark
" colorscheme molokai 
" colorscheme codedark 
colorscheme PaperColor

" --------------- Nerd Tree --------------------------------
" nmap <C-n> :NERDTreeToggle<CR>
" let g:NERDTreeWinSize=30 " 表示幅
" let g:NERDTreeShowBookmarks=1 " ブックマークを表示
" let g:NERDTreeMapUpdir='<C-u>'  " 親ディレクトリへ移動
" let g:NERDTreeMapOpenSplit='<C-b>' " ファイルの開き方
" let g:NERDTreeMapOpenVSplit='<C-l>' 
" let g:NERDTreeQuitOnOpen=1 " ファイルを開いたらNERDTreeを閉じる
" let g:NERDTreeShowHidden=1 " 隠しファイルを表示
" let g:NERDTreeIgnore=['\.git$', '\.clean$', '\.swp$', '\.bak$', '\~$'] " 非表示ファイル
" 
" augroup vimrc_nerdtree 
"   autocmd!
"   " 他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
"   autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif
"   " Tree内では5ずつ移動する
"   autocmd FileType nerdtree nnoremap 5j
"   autocmd FileType nerdtree nnoremap 5k
" augroup END

" let NERDTreeMapOpenInTab='<ENTER>' " Enterキーで新しいタブで開く


" ---------------  airline --------------------------------
" Airline SETTINGS
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
" let g:airline_theme = 'onedark'
let g:airline_theme = 'codedark'
" let g:airline_theme = 'molokai'

" タブの切り替え
nmap <C-p> <Plug>AirlineSelectPrebTab
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



" ---------------  winresizer --------------------------------
" let g:winresizer_gui:w_enable = 1
" let g:winrisizer_vert_resize=1
" let g:winresizer_horiz_resize=1
" let g:winresizer_start_key = '<C-t>'
" " If you want to cancel and quit window resize mode by `z` (keycode 122)
" let g:winresizer_keycode_cancel = 122
" " To expand your window size toward upper using upper arrow (instead of k)
" let g:winresizer_keycode_up = "\<UP>"
" " To expand your window size toward lower using down arrow (instead of j)
" let g:winresizer_keycode_down = "\<DOWN>"


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
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>


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

let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11",
            \ "BreakBeforeBraces" : "Stroustrup"}

" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
nmap <Leader>C :ClangFormatAutoToggle<CR>

let g:python3_host_prog = "/usr/bin/python3" 
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"



" ---------------   LSPのセッティング

lua << EOF
    local on_attach = function (client, bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap=true,silent=true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', {noremap=true,silent=true})
    end
    -- require('lspconfig').vimls.setup({on_attach = on_attach})
    -- require('lspconfig').tsserver.setup({on_attach = on_attach})
    -- require('lspconfig').intelephense.setup({on_attach = on_attach})
    -- インストールしたサーバーを起動させる
    local lsp_installer = require("nvim-lsp-installer")
    lsp_installer.on_server_ready(function(server)
        local opts = {on_attach = on_attach}
        opts.capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
        -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
        server:setup(opts)
        vim.cmd [[ do User LspAttachBuffers ]]
    end)

    -- 補完機能の設定
    vim.opt.completeopt = "menu,menuone,noselect"
    local cmp = require("cmp")
    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
          vim.fn["UltiSnips#Anon"](args.body) 
        end,
      },
      mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
  timeout = 2000,
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
EOF
