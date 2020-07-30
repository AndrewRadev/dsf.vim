" Searches for the start of a function call (or anything similar, like
" `Hash[...]`) on the current line, using the flags that were provided.
"
" Returns [success, opening_bracket]
"
function! dsf#SearchFunctionStart(direction)
  let brackets          = dsf#Setting('dsf_brackets')
  let function_pattern  = dsf#Setting('dsf_function_pattern')
  let namespace_pattern = dsf#Setting('dsf_namespace_pattern')
  let cursor_pos        = getpos('.')

  if a:direction == 'forwards'
    let flags = 'Wc'
  elseif a:direction == 'backwards'
    let flags = 'Wb'
  else
    echoerr "Unknown direction: ".a:direction
    return
  endif

  while 1
    let search_result = search(function_pattern.'\zs['.brackets.']', flags)
    if search_result <= 0
      return [0, '']
    endif

    let opening_pos = getpos('.')
    normal %
    let closing_pos = getpos('.')
    normal %

    if a:direction == 'backwards'
      if s:Between(cursor_pos, opening_pos, closing_pos)
        " then the cursor is within the brackets, we're good
        break
      elseif col('.') > 1
        " search is backwards, so we can keep going leftward
        normal! h
        continue
      else
        return [0, '']
      endif
    elseif a:direction == 'forwards'
      " we're not going backwards, so we're okay with jumping to the next
      " function call
      break
    else
      echoerr "Unknown direction: ".a:direction
      return
    endif
  endwhile

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

function! s:Between(target, start, end)
  let target_byte = line2byte(a:target[1]) + a:target[2] - 1
  let start_byte  = line2byte(a:start[1])  + a:start[2]  - 1
  let end_byte    = line2byte(a:end[1])    + a:end[2]    - 1

  return start_byte <= target_byte && target_byte <= end_byte
endfunction
