if exists('g:loaded_dsf') || &cp
  finish
endif

let g:loaded_dsf = '0.1.0' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:dsf_no_mappings')
  let g:dsf_no_mappings = 0
endif

if !exists('g:dsf_brackets')
  let g:dsf_brackets = '([{'
endif

if !exists('g:dsf_function_pattern')
  let g:dsf_function_pattern = '\k\+'
endif

if !exists('g:dsf_namespace_pattern')
  let g:dsf_namespace_pattern = '\k\+\%(\.\|::\)'
endif

if !exists('g:dsf_latex_special_handling')
  let g:dsf_latex_special_handling = 1
endif

autocmd FileType ruby
      \ let b:dsf_function_pattern = '\k\+[?!.]\='
autocmd FileType rust
      \ let b:dsf_function_pattern  = '\k\+!\='
autocmd FileType css,scss,less
      \ let b:dsf_function_pattern = '\(\k\|-\)\+'

autocmd FileType tex
      \ let b:dsf_function_pattern = '\\\k\+'

autocmd FileType vim
      \ let b:dsf_namespace_pattern = '\k\+\%(\.\|:\|#\)'

nnoremap <silent> <Plug>DsfDelete :call <SID>DeleteSurroundingFunctionCall()<cr>
function! s:DeleteSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('backwards', 'cursor')
  if !success
    return
  endif

  call s:Delete(opening_bracket)

  silent! call repeat#set("\<Plug>DsfDelete")
endfunction

nnoremap <silent> <Plug>DsfNextDelete :call <SID>DeleteNextSurroundingFunctionCall()<cr>
function! s:DeleteNextSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('forwards', 'global')
  if !success
    " fall back to the standard case
    return s:DeleteSurroundingFunctionCall()
  endif

  call s:Delete(opening_bracket)

  silent! call repeat#set("\<Plug>DsfNextDelete")
endfunction

" Actually perform the deletion -- expects to be at the start of a function call.
function! s:Delete(opening_bracket)
  let start_line = line('.')
  let saved_view = winsaveview()

  " delete everything up to the bracket
  exe 'normal! dt'.a:opening_bracket

  " jump to the matching bracket
  normal %
  let closing_bracket = getline('.')[col('.') - 1]
  let end_line = line('.')

  if line('.') > 1 && search('^\s*\%#', 'Wbcn', line('.'))
    " then we have a multiline closing bracket, delete till the previous line
    normal! vk$"_d
    let end_line -= 1
  elseif search('\s\+\%#', 'Wb', line('.'))
    " then we have whitespace before the line, clear it
    exe 'normal! "_df'.closing_bracket
  else
    " just the bracket, delete it
    normal! "_x
  endif

  if g:dsf_latex_special_handling && &ft == 'tex'
    " after the closing bracket, there might be another set of brackets, and
    " we'd be on top of them:
    for bracket_pair in ['{}', '[]']
      let opening = bracket_pair[0]
      let closing = bracket_pair[1]

      if getline('.')[col('.') - 1] == opening
        normal %

        if getline('.')[col('.') - 1] == closing
          exe 'normal! da'.closing
          break
        endif
      endif
    endfor
  endif

  call winrestview(saved_view)

  exe 'keeppatterns s/\%#'.escape(a:opening_bracket, '[').'\_s*//'
  if end_line - start_line > 1
    exe start_line.','.(end_line - 1).'normal! v='
  endif

  call winrestview(saved_view)
endfunction

nnoremap <silent> <Plug>DsfChange :call <SID>ChangeSurroundingFunctionCall()<cr>
function! s:ChangeSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('backwards', 'cursor')
  if !success
    return
  endif

  call feedkeys('ct'.opening_bracket, 'n')
endfunction

nnoremap <silent> <Plug>DsfNextChange :call <SID>ChangeNextSurroundingFunctionCall()<cr>
function! s:ChangeNextSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('forwards', 'global')
  if !success
    " fall back to the standard case
    return s:ChangeSurroundingFunctionCall()
  endif

  call feedkeys('ct'.opening_bracket, 'n')
endfunction

" Operate on a function call
onoremap <Plug>DsfTextObjectA :<c-u>call <SID>FunctionCallTextObject('a')<cr>
xnoremap <Plug>DsfTextObjectA :<c-u>call <SID>FunctionCallTextObject('a')<cr>
onoremap <Plug>DsfTextObjectI :<c-u>call <SID>FunctionCallTextObject('i')<cr>
xnoremap <Plug>DsfTextObjectI :<c-u>call <SID>FunctionCallTextObject('i')<cr>

function! s:FunctionCallTextObject(mode)
  let [success, opening_bracket] = dsf#SearchFunctionStart('forwards', 'cursor')
  if !success
    let [success, opening_bracket] = dsf#SearchFunctionStart('backwards', 'cursor')
  endif

  if !success
    return
  endif

  if a:mode == 'i'
    exe 'normal! f'.opening_bracket.'vi'.opening_bracket
    return
  endif

  " a:mode == 'a':

  if !g:dsf_latex_special_handling || &ft != 'tex'
    exe 'normal! vf'.opening_bracket.'%'
    return
  endif

  " Filetype is 'tex', special handling:

  " after the closing bracket, there might be another set of brackets,
  " move to the closing and then right to find them:
  let saved_view = winsaveview()

  exe 'normal! f'.opening_bracket.'%'
  let byte_position = line2byte(line('.')) + col('.') - 1
  normal! l

  for bracket_pair in ['{}', '[]']
    let opening = bracket_pair[0]
    let closing = bracket_pair[1]

    if getline('.')[col('.') - 1] == opening
      normal %

      if getline('.')[col('.') - 1] == closing
        let byte_position = line2byte(line('.')) + col('.') - 1
        break
      endif
    endif
  endfor

  call winrestview(saved_view)
  exe 'normal! vf'.opening_bracket.byte_position.'go'
endfunction

if !g:dsf_no_mappings
  nmap dsf <Plug>DsfDelete
  nmap csf <Plug>DsfChange

  nmap dsnf <Plug>DsfNextDelete
  nmap csnf <Plug>DsfNextChange

  omap af <Plug>DsfTextObjectA
  xmap af <Plug>DsfTextObjectA
  omap if <Plug>DsfTextObjectI
  xmap if <Plug>DsfTextObjectI
endif

let &cpo = s:keepcpo
unlet s:keepcpo
