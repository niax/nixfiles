" Picker Configs (snacks.nvim)
nnoremap <C-p> <cmd>lua Snacks.picker.files()<cr>
nnoremap <space>/ <cmd>lua Snacks.picker.grep()<cr>
nnoremap <space>b <cmd>lua Snacks.picker.buffers()<cr>

" lightline Configs
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
