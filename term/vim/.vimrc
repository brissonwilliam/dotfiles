" basic vim configs and overrides

" custom remaps
nnoremap {{ 0v$%
nnoremap Q @q
nnoremap <S-k> O<Esc>j
nnoremap <S-j> o<Esc>k
inoremap jj <Esc>

"reload
nnoremap <C-l> :source ~/.vimrc <CR>

" paste visual select without overriding register when deleting
vnoremap p "_dP

" delete without inserting in vim clipboard (in void buff)
vnoremap <Space>d "_d
nnoremap <Space>dd "_dd
nnoremap <Space>D "_D

" copy to clipboard
vnoremap <Space>y "+y
nnoremap <Space>yy "+yy
nnoremap <Space>Y "+Y

" copy relpath to clipbaord
nnoremap <Space>5 :let @+ = expand('%')<CR>

" move blocks in visual mode with indent
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" keep code centered when moving in file
nnoremap <C-u> <C-u>z.
nnoremap <C-d> <C-d>z.

" z<CR> to navigate to top of screen
" z. to navigate to middle of screen
" z- to navigate to bottom of screen

" mg to set a marker
" 'g to go to marker

set termguicolors
if !has('gui_running')
  set t_Co=256
endif

" tabs take too much space
set tabstop=4
set shiftwidth=4
" auto expand
set expandtab

" line number bar
set number
set relativenumber
set numberwidth=3

" extra space besides line (for constant git gutter)
set signcolumn=yes

" autoreaload files
set autoread

" undo historry
set history=1000

" timeout of keystrokes sequenece
set ttimeoutlen=40

" file refresh time (useful for git gutter)
set updatetime=400

" inc search (move the exact finding when searching with /)
set nohlsearch
set incsearch

" page scrolloff
set scrolloff=12

" always show tabline  
set showtabline=2

" status powerline
set laststatus=2

" highlighting
set cursorline

set ttyfast

" autocomplete filetypes
filetype plugin on

" syntax highlight (basic
syntax on

" remove auto comment on newline
autocmd FileType * set fo-=r fo-=o

" fix yaml copy pasta and indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" no swapfiles
set noswapfile

" cursor bar in insert mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" configure plugins / plug
if has('nvim')
else	
    " set background=dark
    colorscheme elflord
    highlight EndOfBuffer guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE
    highlight NonText    guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE
endif


" some 'tender' overrides for better visibility
" line numbers more visible (dark in tender)
" Float bg set to black for contrast
" Lines around windows and various splits. Defaults to same color as bg which
" is annoying and not pretty
" highlight LineNr term=bold ctermfg=White guifg=Grey
" highlight CursorLineNr term=bold cterm=NONE ctermbg=NONE ctermfg=DarkGrey gui=bold guibg=NONE guifg=#bbbbbb
" hi NormalFloat guibg=Black
" highlight VertSplit ctermfg=White guifg=White guibg=Black
" hi TabLineSel gui=bold

" tabline
function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let name = expand('#' . buflist[winnr - 1] . ':t')
  let sign = gettabwinvar(a:n, winnr, '&modified') ? '+' : ''
  return '[' . a:n . '] ' . name  . ' ' . sign
endfunction

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s ..= '%#TabLineSel#'
    else
      let s ..= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s ..= '%' .. (i + 1) .. 'T'

    " the label is made by MyTabLabel()
    let s ..= ' %{MyTabLabel(' .. (i + 1) .. ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s ..= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s ..= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction
set tabline=%!MyTabLine()

" file tree nerdtree configs
" nnoremap <C-f> :NERDTreeFind<cr>
" nnoremap <C-t> :NERDTreeToggle<cr>
" let g:NERDTreeShowHidden = 1
" let g:NERDTreeQuitOnOpen = 1
" let g:NERDTreeGitStatusIndicatorMapCustom = {
" 	\ 'Modified'  :'✹',
" 	\ 'Staged'    :'✚',
" 	\ 'Untracked' :'✭',
" 	\ 'Renamed'   :'➜',
" 	\ 'Unmerged'  :'═',
" 	\ 'Deleted'   :'✖',
" 	\ 'Dirty'     :'✗',
" 	\ 'Ignored'   :'☒',
" 	\ 'Clean'     :'✔︎',
" 	\ 'Unknown'   :'?',
" \ }
" let g:NERDTreeGitStatusUseNerdFonts = 1 

" telescope fuzzy finding, files, buffers and stuff 
" C-m is carriage return (ENTER). I remapped to control-m to a random unicode character 
nnoremap ¤ :lua require('telescope.builtin').find_files({ cwd = require('telescope.utils').buffer_dir() })<CR>
nnoremap <C-n> :Telescope find_files<CR>
nnoremap <C-s> :Telescope live_grep_args<CR>
nnoremap <S-Tab> :Telescope resume<CR>
nnoremap <C-z> :Telescope git_status<cr>
nnoremap <C-h> :Telescope git_commits<cr>
nnoremap <C-o> :Telescope buffers<cr> 
" mapped to ctrl-i in my terminal, as this control character is used for other

" fix an issue with icons when re-sourcing vimrc
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif

" buffers
nnoremap gq :bdelete<CR>
nnoremap gQ :%bdelete<CR>

" tabs 
nnoremap g< :-tabm<CR>
nnoremap g> :+tabm<CR>

nnoremap g1 :tabn 1<CR>
nnoremap g2 :tabn 2<CR>
nnoremap g3 :tabn 3<CR>
nnoremap g4 :tabn 4<CR>
nnoremap g5 :tabn 5<CR>
nnoremap g6 :tabn 6<CR>
nnoremap g6 :tabn 6<CR>
nnoremap g7 :tabn 7<CR>
nnoremap g8 :tabn 8<CR>
nnoremap g9 :tabn 9<CR>
nnoremap gb :tabprevious<CR>
nnoremap gn :tabnext<CR>
nnoremap <C-t> :tab new<CR>

" window resize 
" <C-w>s for split  
" <C-w>v for vertical split  
" <C-w>q to quit 
nnoremap <C-w>< :wincmd x<cr>
nnoremap <C-up> :resize +3<cr>
nnoremap <C-down> :resize -3<cr>
nnoremap <C-right> :vertical resize +3<cr>
nnoremap <C-left> :vertical resize -3<cr>
nnoremap gs :split<cr>
nnoremap gv :vsplit<cr>


" vim multiple cursors
let g:VM_default_mappings = 0
let g:VM_maps = {}
let g:VM_maps["Select Operator"] = ''
let g:VM_maps["Undo"] = 'u'
let g:VM_maps["Redo"] = '<C-r>'
let g:VM_maps["Exit"]               = '<Esc>'
let g:VM_maps['Find Under']         = '<C-h>'
let g:VM_maps['Find Subword Under'] = '<C-h>'
let g:VM_maps['Add Cursor Down'] = '<C-j>'
let g:VM_maps['Add Cursor Up'] = '<C-k>'

if has('nvim')
    " lsp theme overrides
	" personal overrides
	" :hi to see highlights configured
	" hi link @lsp.type.method Constant 

	" defaults
	" for some reason those don't get linked and applied properly
	" hi! link Conditional Keyword 
	" hi link @lsp.type.namespace Include
	" hi link @lsp.type.typePrameter Typedef 
	" hi link @lsp.type.operator Operator 
	" more lsp, dap, tree and nvim lua custom configs and modules

	lua require("init")

	" git
	nnoremap zb :Git blame<CR>
	nnoremap zp :lua require'gitsigns'.preview_hunk()<CR>
	nnoremap zu :lua require'gitsigns'.reset_hunk()<CR>
	nnoremap za :Git add .<CR>
	nnoremap zr :Git reset .<CR>
	nnoremap zl :0GcLog<CR>
	nnoremap zdd :horizontal rightbelow Git diff<CR>
	nnoremap zdv :vertical rightbelow Git diff<CR>
	nnoremap zdt :tab rightbelow Git diff<CR>
	nnoremap zs :horizontal belowright Git<CR>
	nnoremap zj :lua require'gitsigns'.nav_hunk('next')<CR>
	nnoremap zk :lua require'gitsigns'.nav_hunk('prev')<CR>

	" debug
	nnoremap <C-b>b :DapToggleBreakpoint<CR>
	nnoremap <C-b><C-b> :DapToggleBreakpoint<CR>
	nnoremap <C-b>d :DapClearBreakpoints<CR>
	nnoremap <C-b><C-d> :DapClearBreakpoints<CR>
	nnoremap <C-b>q :DapTerminate<CR>
	nnoremap <C-b><C-q> :DapTerminate<CR>
	" nnoremap <C-b><C-o> :lua require'dapui'.toggle()<CR>
	" nnoremap <C-b><C-p> :lua require("dapui").float_element()<CR>
	" nnoremap <C-b>p :lua require("dapui").float_element()<CR>
	nnoremap <F12> :DapViewToggle<CR>
	nnoremap <F9> :DapContinue<CR>
	nnoremap <F8> :DapStepOver<CR>
	nnoremap <F7> :DapStepInto<CR>
	lua vim.fn.sign_define('DapBreakpoint', {text='', texthl='red', linehl='', numhl=''})
	lua vim.fn.sign_define('DapStopped', {text='󱞪', texthl='red', linehl='', numhl=''})

	" lsp
	nnoremap <F5> :lua vim.lsp.codelens.run() <CR>
	nnoremap re :lua vim.lsp.buf.rename()<CR>
	nnoremap gl :LspRestart<CR>

    " diagnostics
    " https://neovim.io/doc/user/diagnostic.html
    nnoremap gk :lua vim.diagnostic.jump({count=-1, severity=vim.diagnostic.severity.ERROR})<CR>
    nnoremap gj :lua vim.diagnostic.jump({count=1, severity=vim.diagnostic.severity.ERROR})<CR>
	nnoremap gp :lua vim.diagnostic.open_float()<CR>
    nnoremap <C-q> :lua require('telescope.builtin').diagnostics({severity=vim.diagnostic.severity.ERROR, width = 80})<cr> 


	nnoremap gr :Telescope lsp_references<CR>
	nnoremap gi :Telescope lsp_implementations<CR>
	nnoremap gtd :Telescope lsp_type_definitions<CR>
	nnoremap gtt <cmd>tab split \| lua vim.lsp.buf.type_definition()<CR>
	nnoremap gtv :vsplit<CR><C-w>l :lua vim.lsp.buf.type_definition()<CR>

	nnoremap gdd :lua vim.lsp.buf.definition({reuse_win=true})<CR>
	nnoremap gdt <cmd>tab split \| lua vim.lsp.buf.definition()<CR>
	nnoremap gdv :vsplit<CR><C-w>l :lua vim.lsp.buf.definition()<CR>

    silent! unmap gcc
    silent! unmap gri
    silent! unmap grr
    silent! unmap gra
    silent! unmap gra
    silent! unmap grn


	nnoremap <C-p> :lua vim.lsp.buf.hover()<CR>

    " nvim-tree
    nnoremap <C-f> :NvimTreeFindFileToggle<CR>

    " ai autocomplete
    nnoremap <Space>o :CopilotChatToggle<CR>
    nnoremap <Space><Esc> :CopilotChatStop<CR>

    " nnoremap <Space>e :Copilot enable<CR>
    " imap <silent><script><expr> <C-a> copilot#Accept("\<CR>")
    " let g:copilot_no_tab_map = v:true
    " imap <C-L> <Plug>(copilot-next)
    " imap <C-H> <Plug>(copilot-previous)
    " imap <C-W> <Plug>(copilot-accept-word)

endif

" INSERT mode message
hi ModeMsg gui=bold ctermfg=White guifg=White guibg=Black

