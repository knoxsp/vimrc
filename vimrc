" ~/.vimrc - sensible baseline + Python/JS/Vue dev setup
" -----------------------------------------------------

" --- Core sanity ---
set nocompatible              " vim, not vi
syntax on                     " syntax highlighting
filetype plugin indent on     " filetype-aware plugins & indenting
set encoding=utf-8
set hidden                    " allow switching buffers without saving
set autoread                  " reload files changed outside vim

" --- Indentation (2-space default; overridden per-language below) ---
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent

" --- Search ---
set incsearch
set hlsearch
set ignorecase
set smartcase                 " case-sensitive if search has capitals

" --- UI ---
set number
set cursorline
set showcmd
set wildmenu                  " command-line completion menu
set wildmode=longest:full,full
set scrolloff=8
set signcolumn=yes
set laststatus=2
set noerrorbells visualbell t_vb=
set colorcolumn=88

" --- Mouse (so Vim handles selection instead of the terminal) ---
set mouse=a

" --- Clipboard over SSH (OSC 52) ---
" Every yank is pushed to your LOCAL terminal's clipboard via an escape
" sequence, so `y` works the same whether you're local or ssh'd in.
let g:oscyank_term = 'default'
autocmd TextYankPost * if v:event.operator ==# 'y' | OSCYankRegister '"' | endif

" --- Splits ---
set splitright
set splitbelow

" --- Backups/swap out of the way ---
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
set undofile
silent !mkdir -p ~/.vim/backup ~/.vim/swap ~/.vim/undo

" --- Leader key ---
let mapleader = ","

" --- Basic quality-of-life mappings ---
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>/ :nohlsearch<CR>
nnoremap <leader>e :Explore<CR>

" --- Clipboard (use system clipboard where available) ---
set clipboard=unnamedplus

" =========================================================
" Plugin manager: vim-plug
" Install steps are in the accompanying README.
" =========================================================
call plug#begin('~/.vim/plugged')

" General / IDE-like features
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

" Linting / formatting (ALE) + LSP (vim-lsp - works on Vim 8.1+, no Vim9 requirement)
Plug 'dense-analysis/ale'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Python
Plug 'vim-python/python-syntax'
Plug 'Vimjas/vim-python-pep8-indent'

" JavaScript / Vue
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'posva/vim-vue'
Plug 'leafgarland/typescript-vim'

" Clipboard over SSH
Plug 'ojroques/vim-oscyank'

call plug#end()

" =========================================================
" Plugin configuration
" =========================================================

" Colorscheme
set background=dark
silent! colorscheme gruvbox

" Tone down Visual-mode selection highlight (default gruvbox is quite strong,
" including the number gutter during linewise (V) selection - this is
" default Vim behaviour, not fixable outright, just softened here)
highlight Visual cterm=none ctermbg=237 guibg=#3a3a3a

" NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>

" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <leader>b :Buffers<CR>

" ALE (lint/fix on save; keep it fast and quiet)
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'javascript': ['eslint'],
\   'vue': ['eslint'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black', 'isort'],
\   'javascript': ['prettier', 'eslint'],
\   'vue': ['prettier'],
\}
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:ale_sign_column_always = 1

" vim-lsp / asyncomplete
" Language servers auto-install per filetype the first time you open one -
" vim-lsp-settings will prompt with :LspInstallServer. See README.
set completeopt=menuone,noinsert,noselect
let g:lsp_diagnostics_enabled = 0
let g:asyncomplete_auto_completeopt = 0
nmap <silent> gd <plug>(lsp-definition)
nmap <silent> gr <plug>(lsp-references)
nmap <silent> <leader>rn <plug>(lsp-rename)
nnoremap <silent> K :LspHover<CR>

" python-syntax
let g:python_highlight_all = 1

" vim-vue: make sure .vue files are recognised
autocmd BufNewFile,BufRead *.vue setlocal filetype=vue

" --- Per-language indent overrides ---
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType javascript,vue,typescript,json setlocal tabstop=2 shiftwidth=2 softtabstop=2
