" Plugins directory
call plug#begin('~/.local/share/nvim/plugged')
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'tpope/vim-fugitive'
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
call plug#end()

runtime! plugin/rplugin.vim
silent! UpdateRemotePlugins

if (has("termguicolors"))
    set termguicolors
endif

" Theme
syntax enable
"colorscheme tokyonight
set tabstop=2 shiftwidth=2 expandtab

" Mappings
map <F2> :NERDTreeToggle<CR>
map <F8> :make<CR>

" Autoloads
autocmd VimEnter * AirlineTheme dark

" Ensures color escape characters show properly
"if @% != ""
""    autocmd VimEnter *.log term cat %
"endif

let g:deoplete#enable_at_startup = 1