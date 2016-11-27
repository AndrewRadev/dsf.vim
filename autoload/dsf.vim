" Searches for the start of a function call (or anything similar, like
" `Hash[...]`) on the current line, using the flags that were provided.
"
" Returns [success, opening_bracket]
"
function! dsf#SearchFunctionStart(flags)
  let brackets          = dsf#Setting('dsf_brackets')
  let function_pattern  = dsf#Setting('dsf_function_pattern')
  let namespace_pattern = dsf#Setting('dsf_namespace_pattern')

  if search(function_pattern.'\zs['.brackets.']', a:flags, line('.')) <= 0
    return [0, '']
  endif

  " what's the opening bracket?
  let opener = getline('.')[col('.') - 1]

  " go back to get to the beginning of the function call
  call search(function_pattern, 'b', line('.'))

  if namespace_pattern != ''
    " now we're on the function's name, see if we should move back some more
    " over any namespaces
    let prefix = strpart(getline('.'), 0, col('.') - 1)
    while prefix =~ namespace_pattern.'$'
      if search(namespace_pattern, 'b', line('.')) <= 0
        break
      endif
      let prefix = strpart(getline('.'), 0, col('.') - 1)
    endwhile
  endif

  return [1, opener]
endfunction

function! dsf#Setting(key)
  return get(b:, a:key, get(g:, a:key))
endfunction
