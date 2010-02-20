" smartchr - Insert several candidates with a single key
" Version: 0.1.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Public API  "{{{1
function! smartchr#loop(...)  "{{{2
  "  a:000 = [a:1, a:2, ..., a:{N}, {context}]
  "  looped_args = [a:1, a:2, ..., a:{N}, a:1, {context}]
  "  Note that {context} may be omitted.

  if s:context_p(a:000[-1])
    let looped_args = copy(a:000)  " Destroying a:value may be harmful.
    call insert(looped_args, a:1, -1)
  else
    let looped_args = a:000 + [(a:1)]
  endif

  return call('smartchr#one_of', looped_args)
endfunction




function! smartchr#one_of(...)  "{{{2
  let last_arg = a:000[-1]
  if s:context_p(last_arg)
    let context = last_arg
    let literals = a:000[:-2]
  else
    let context = s:DEFAULT_CONTEXT
    let literals = a:000
  endif

  for i in range(len(literals) - 1, 1, -1)
    let literal1 = literals[i]
    let literal2 = literals[i-1]

    if s:cursor_preceded_with_p(literal2)
      return (pumvisible() ? "\<C-e>" : '')
           \ . repeat("\<BS>", len(literal2))
           \ . literal1
    endif
  endfor

  return a:1
endfunction








" Misc.  "{{{1
" Variables  "{{{2

let s:DEFAULT_CONTEXT = {}




function! smartchr#_sid()  "{{{2
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID>  <SID>




function! s:context_p(value)  "{{{2
  return type(a:value) == type({})
endfunction




function! s:cursor_preceded_with_p(s)  "{{{2
  if mode()[0] ==# 'c'
    " Command-line mode.
      " getcmdpos() is 1-origin and we want to the position of the character
      " just before the cursor.
    let p = getcmdpos() - 1 - 1
    let l = len(a:s)
    return l <= p + 1 && getcmdline()[p - l + 1: p] ==# a:s
  else
    " Insert mode and other modes except Commnd-line mode.
    return search('\V' . escape(a:s, '\') . '\%#', 'bcn')
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
