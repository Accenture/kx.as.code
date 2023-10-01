" Plugins directory
call plug#begin('~/.local/share/nvim/plugged')
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'tpope/vim-fugitive'
    Plug 'z0mbix/vim-shfmt', { 'for': 'sh' }
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
call plug#end()

runtime! plugin/rplugin.vim
silent! UpdateRemotePlugins

" Mappings
map <F2> :NERDTreeToggle<CR>
map <F8> :make<CR>

" Theme
let g:airline_powerline_fonts = 1
let g:airline_solarized_bg = "dark"
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = "luna"
let g:deoplete#enable_at_startup = 1
let airline_skip_empty_section = 1
let g:shfmt_extra_args = '-i 2'
let g:shfmt_fmt_on_save = 1
let g:airline_section_warning = ''
let g:airline_section_error = ''
colorscheme slate
syntax enable