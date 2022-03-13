" File options
if has("autocmd")
 filetype plugin on
 filetype indent on
endif "has("autocmd")

set backupdir=~/.vim-backups
set dir=~/.vim-swap

" Default stops
set backspace=indent,eol,start "Backspace indent, over line breaks and outside of insert
set tabstop=4
set shiftwidth=4
set noexpandtab
set autoindent
set smartcase "Case insensitve matching
set ruler "Always show status bar
set laststatus=2 " (also) always show the status bar
set history=1000

" Enable the mouse
set mouse=a

set number
set nohlsearch " don't keep highlighting last search
syntax enable
set background=dark
set t_Co=256

" Solarized Colorscheme Config
let g:solarized_termtrans=0    "default value is 0
let g:solarized_termcolors=256   "default value is 16
let g:solarized_contrast="high"    "default value is normal
let g:solarized_visibility="high"    "default value is normal
let g:solarized_hitrail=0    "default value is 0
colorscheme solarized
