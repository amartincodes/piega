" piega.vim - Bootstrap file for traditional plugin managers
" Maintainer: Piega Contributors

" Prevent loading twice
if exists('g:loaded_piega')
  finish
endif
let g:loaded_piega = 1

" Ensure Neovim version is compatible
if !has('nvim-0.7.0')
  echohl WarningMsg
  echom 'piega.nvim requires Neovim >= 0.7.0'
  echohl None
  finish
endif

" Define user commands
command! PiegaFoldScope lua require('piega').fold_scope()
command! PiegaUnfoldAll lua require('piega').unfold_all()
command! PiegaFoldLevel lua require('piega').fold_level()

" Optional: Auto-setup with default config if user hasn't called setup()
" Users can override by calling setup() in their config
augroup PiegaAutoSetup
  autocmd!
  autocmd VimEnter * ++once lua if not require('piega').is_initialized() then require('piega').setup() end
augroup END
