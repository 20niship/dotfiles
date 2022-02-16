" https://note.com/histone/n/na8ebb8a5909f のプラグインより
" フォントのインストールは --> mkdir -p ~/.local/share/fonts; cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

set guifont=DroidSansMono\ Nerd\ Font\ 13
set guifontwide=DroidSansMono\ Nerd\ Font\ 13
set hlsearch
set laststatus=2
set ruler
set history=1000
set number "行頭に数字を表示する
set foldmethod=marker "foldを使用する           
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
" set foldtext=Mopp_fold() " 折りたたみ時の表示設定
" set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo " fold内に移動すれば自動で開く
set nofoldenable    " disable folding



" 閉じカッコの自動補間
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>

set encoding=utf8
syntax enable

let g:vimsyn_embed='lPr' " Luaでシンタックスハイライト


" Esc SETTINGS
inoremap jk <Esc>
inoremap jj <Esc>

" #################    DEINの設定   ###################
if &compatible                                                                                                                      
  set nocompatible               " Be iMproved                      
endif

" Required:
set runtimepath+=/home/owner/.cache/dein/repos/github.com/Shougo/dein.vim

call dein#begin('/home/owner/.cache/dein')                          
  call dein#add('/home/owner/.cache/dein/repos/github.com/Shougo/dein.vim')

  " VSCodeのようなカラースキームにする(カッコが見にくいので却下)
  " call dein#add('tomasiser/vim-code-dark')
  call dein#add('joshdick/onedark.vim')

  " ファイル表示
  " call dein#add('preservim/nerdtree')

  " airline : ステータスバーをかっこよくする
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('ryanoasis/vim-devicons')


  call dein#add('neovim/nvim-lspconfig')
  call dein#add('nvim-lua/completion-nvim')
  " deocomplete : Vimの補完プラグインneocompleteのNeoVim版
  " call dein#add('Shougo/deoplete.nvim')
  " if !has('nvim')
  "   call dein#add('roxma/nvim-yarp')
  "   call dein#add('roxma/vim-hug-neovim-rpc')
  " endif

  " Windowのリサイズをやりやすくする
  call dein#add('simeji/winresizer')

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
call dein#end()

filetype plugin indent on         

" If you want to install not installed plugins on startup.          
"if dein#check_install()          
"  call dein#install()            
"endif                            



" ################# 各種プラグインの設定 #################
colorscheme onedark

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
let g:airline_theme = 'onedark'
set laststatus=2                " 下のステータスライン
set noshowmode                  " デフォルトのステータスラインを消す
set showtabline=2
set statusline=2                " ステータスラインの記述



" Esc SETTINGS
inoremap jk <Esc>
inoremap jj <Esc>

" /// Enable Netrw (default file browser)
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



" ---------------  lspconfig --------------------------------
lua << EOF
    local on_attach = function (client, bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
        require('completion').on_attach(client)
    end
    require('lspconfig').vimls.setup({on_attach = on_attach})
    require('lspconfig').tsserver.setup({on_attach = on_attach})
    require('lspconfig').intelephense.setup({on_attach = on_attach})
EOF


" ---------------  deoplete --------------------------------
let g:deoplete#enable_at_startup = 1



" ---------------  winresizer --------------------------------
" " let g:winresizer_gui:w
"_enable = 1
" let g:winrisizer_vert_resize=1
" let g:winresizer_horiz_resize=1
" " let g:winresizer_start_key = '<C-t>'
" " If you want to cancel and quit window resize mode by `z` (keycode 122)
" let g:winresizer_keycode_cancel = 122
" " To expand your window size toward upper using upper arrow (instead of k)
" let g:winresizer_keycode_up = "\<UP>"
" " To expand your window size toward lower using down arrow (instead of j)
" let g:winresizer_keycode_down = "\<DOWN>"



" ---------------  coc settings --------------------------------
" "function! s:show_documentation()
" "  if (index(['vim','help'], &filetype) >= 0)
" "    execute 'h '.expand('<cword>')
" "  elseif (coc#rpc#ready())
" "    call CocActionAsync('doHover')
" "  else
" "    execute '!' . &keywordprg . " " . expand('<cword>')
" "  endif
" "endfunction
" "" Highlight the symbol and its references when holding the cursor.
" "autocmd CursorHold * silent call CocActionAsync('highlight')
" "augroup mygroup
" "  autocmd!
" "  " Setup formatexpr specified filetype(s).
" "  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
" "  " Update signature help on jump placeholder.
" "  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
" "augroup end
" "command! -nargs=0 Format :call CocAction('format')
" "command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" "command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" "

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
  
nnoremap <C-n> :Fern . -reveal=% -drawer -toggle -width=40<CR>




" デフォルトのLeaderキー： " \ "  

" ---------------  telescope --------------------------------
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Using Lua functions
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>


