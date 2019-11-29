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

autocmd FileType ruby let b:dsf_function_pattern  = '\k\+[?!.]\='
autocmd FileType rust let b:dsf_function_pattern  = '\k\+!\='
autocmd FileType vim  let b:dsf_namespace_pattern = '\k\+\%(\.\|:\|#\)'

nnoremap <silent> <Plug>DsfDelete :call <SID>DeleteSurroundingFunctionCall()<cr>
function! s:DeleteSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('backwards')
  if !success
    return
  endif

  call s:Delete(opening_bracket)

  silent! call repeat#set("\<Plug>DsfDelete")
endfunction

nnoremap <silent> <Plug>DsfNextDelete :call <SID>DeleteNextSurroundingFunctionCall()<cr>
function! s:DeleteNextSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('forwards')
  if !success
    " fall back to the standard case
    return s:DeleteSurroundingFunctionCall()
  endif

  call s:Delete(opening_bracket)

  silent! call repeat#set("\<Plug>DsfNextDelete")
endfunction

" Actually perform the deletion -- expects to be at the start of a function call.
function! s:Delete(opening_bracket)
  " delete everything up to the bracket
  exe 'normal! dt'.a:opening_bracket
  " delete the matching bracket, and then this one
  normal %
  normal! "_x``"_x
endfunction

nnoremap <silent> <Plug>DsfChange :call <SID>ChangeSurroundingFunctionCall()<cr>
function! s:ChangeSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('backwards')
  if !success
    return
  endif

  call feedkeys('ct'.opening_bracket, 'n')
endfunction

nnoremap <silent> <Plug>DsfNextChange :call <SID>ChangeNextSurroundingFunctionCall()<cr>
function! s:ChangeNextSurroundingFunctionCall()
  let [success, opening_bracket] = dsf#SearchFunctionStart('forwards')
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
  let [success, opening_bracket] = dsf#SearchFunctionStart('forwards')
  if !success
    let [success, opening_bracket] = dsf#SearchFunctionStart('backwards')
  endif

  if !success
    return
  endif

  if a:mode == 'i'
    exe 'normal! f'.opening_bracket.'vi'.opening_bracket
  else " a:mode == 'a'
    exe 'normal! vf'.opening_bracket.'%'
  endif
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
