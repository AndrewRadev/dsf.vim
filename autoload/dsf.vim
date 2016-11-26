" Searches for the start of a function call (or anything similar, like
" `Hash[...]`) on the current line, using the flags that were provided.
"
" Returns [success, opening_bracket]
"
function! dsf#SearchFunctionStart(flags)
  let original_iskeyword = &iskeyword

  try
    set iskeyword+=?,!

    if search('\k\+\zs[([{]', a:flags, line('.')) <= 0
      return [0, '']
    endif

    " what's the opening bracket?
    let opener = getline('.')[col('.') - 1]

    " go back one word to get to the beginning of the function call
    normal! b

    " now we're on the function's name, see if we should move back some more
    let prefix = strpart(getline('.'), 0, col('.') - 1)
    while prefix =~ '\k\(\.\|::\|:\|#\)$'
      if search('\k\+', 'b', line('.')) <= 0
        break
      endif
      let prefix = strpart(getline('.'), 0, col('.') - 1)
    endwhile

    return [1, opener]
  finally
    let &iskeyword = original_iskeyword
  endtry
endfunction
