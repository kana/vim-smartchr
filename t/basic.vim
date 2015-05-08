call vspec#hint({'sid': 'smartchr#_sid()', 'scope': 'smartchr#_scope()'})

" Refresh Vim's internal information on the cursor position.
" Vim doesn't update the information while inserting characters
" noninteractively, e.g., ":normal! i_foo_bar".
" So we have to refresh it explicitly to test smartchr by a script.
inoremap <Plug>(r)  <C-o><C-l>

" Allow backspacing everything.  Because backspacing doesn't work just after
" <Plug>r that starts new Insert mode as a side effect.
set backspace=indent,eol,start




describe 's:context_p()'
  it 'should return true for {context} value'
    Expect Call('s:context_p', {}) to_be_true
    Expect Call('s:context_p', {'ctype': '/?'}) to_be_true

      " Contents are not checked.
    Expect Call('s:context_p', {'ctype': {'invalid': 'value'}}) to_be_true
    Expect Call('s:context_p', {'invalild': 'key'}) to_be_true
  end

  it 'should return false for non-{context} value'
    Expect Call('s:context_p', 123) to_be_false
    Expect Call('s:context_p', 'string') to_be_false
    Expect Call('s:context_p', ['list']) to_be_false
    Expect Call('s:context_p', function('function')) to_be_false
  end
end




describe 's_cursor_preceded_with_p__in_Command_line_mode'
  before
    new
  end

  after
    quit!
  end

  it 'should return true if the cursor is preceded with specified string.'
    silent execute 'normal!'
    \ ':let b:result = '
    \ "'abc\\.r\<C-r>="
    \ "Call('s:cursor_preceded_with_p', '\\.r')"
    \ "\<Return>'"
    \ "\<Return>"
    Expect b:result ==# 'abc\.r1'

    silent execute 'normal!'
    \ ':let b:result = '
    \ "'abc\\.rx\<Left>\<C-r>="
    \ "Call('s:cursor_preceded_with_p', '\\.r')"
    \ "\<Return>\<End>'"
    \ "\<Return>"
    Expect b:result ==# 'abc\.r1x'

    silent execute 'normal!'
    \ ":abc\<C-r>="
    \ "Call('s:cursor_preceded_with_p', 'abc')"
    \ "\<Return>\<Home>let b:result = '\<End>'"
    \ "\<Return>"
    Expect b:result ==# 'abc1'
  end

  it 'should return false if the cursor is not preceded with specified string.'
    silent execute 'normal!'
    \ ':let b:result = '
    \ "'abcxyz\<C-r>=Call('s:cursor_preceded_with_p', 'foo')\<Return>'"
    \ "\<Return>"
    Expect b:result ==# 'abcxyz0'
  end
end




describe 's_cursor_preceded_with_p__in_Insert_mode'
  before
    " ^\oo \.r baz$
    "         *
    new
    put ='\oo \.r baz'
    normal! $bh
    Expect getline('.') ==# '\oo \.r baz'
    Expect col('.') == 8
    Expect getline('.')[col('.') - 1] ==# ' '
  end

  after
    quit!
  end

  it 'should return true if the cursor is preceded with specified string.'
    silent execute 'normal!'
    \ "i\<C-r>=Call('s:cursor_preceded_with_p', '\\.r')\<Return>"
    Expect getline('.') ==# '\oo \.r2 baz'
  end

  it 'should return false if the cursor is not preceded with specified string.'
    silent execute 'normal!'
    \ "i\<C-r>=Call('s:cursor_preceded_with_p', 'XXX')\<Return>"
    Expect getline('.') ==# '\oo \.r0 baz'
  end
end




describe 's_in_valid_context_p__with_ctype_1'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    inoremap <expr> _  Call('s:in_valid_context_p', {'ctype': ':'})
    cnoremap <expr> _  Call('s:in_valid_context_p', {'ctype': ':'})
    new
  end

  after
    iunmap _
    cunmap _
    quit!
  end

  it 'should return true in Insert mode.'
    silent execute 'normal' 'i_'
    Expect getline('.') ==# '1'
  end

  it 'should return true in ":" Command-line mode, if ctype = ":".'
    silent execute 'normal' ":let b:result = '_'\<Return>"
    Expect b:result ==# '1'
    execute 'silent!' 'normal' "/_\<Return>"
    Expect @/ ==# '0'
  end
end




describe 's_in_valid_context_p__with_ctype_2'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    inoremap <expr> _  Call('s:in_valid_context_p', {'ctype': '/?'})
    cnoremap <expr> _  Call('s:in_valid_context_p', {'ctype': '/?'})
    new
  end

  after
    iunmap _
    cunmap _
    quit!
  end

  it 'should return true in Insert mode.'
    silent execute 'normal' 'i_'
    Expect getline('.') ==# '1'
  end

  it 'should return true in "/" and "?" Command-line mode, if ctype = "/?".'
    silent execute 'normal' ":let b:result = '_'\<Return>"
    Expect b:result ==# '0'
    execute 'silent!' 'normal' "/_\<Return>"
    Expect @/ ==# '1'
    execute 'silent!' 'normal' "?_\<Return>"
    Expect @/ ==# '1'
  end
end




describe 's_in_valid_context_p__with_default_context'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    inoremap <expr> _  Call('s:in_valid_context_p', Ref('s:DEFAULT_CONTEXT'))
    cnoremap <expr> _  Call('s:in_valid_context_p', Ref('s:DEFAULT_CONTEXT'))
    new
  end

  after
    iunmap _
    cunmap _
    quit!
  end

  it 'should return true in any context.'
    " Insert mode
    silent execute 'normal' 'i_'
    Expect getline('.') ==# '1'

    " Command-line mode
    silent execute 'normal' ":let b:result = '_'\<Return>"
    Expect b:result ==# '1'
  end
end




describe 'smartchr_loop'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    inoremap <expr> _  smartchr#loop(' <- ', ' <<< ', '_')
    new
  end

  after
    iunmap _
    quit!
  end

  it 'should insert " <- " for the first time.'
    execute 'normal' "o_"
    Expect getline('.') ==# ' <- '
  end

  it 'should insert " <<< " for the second time.'
    execute 'normal' "o_\<Plug>(r)_"
    Expect getline('.') ==# ' <<< '
  end

  it 'should insert "_" for the third time.'
    execute 'normal' "o_\<Plug>(r)_\<Plug>(r)_"
    Expect getline('.') ==# '_'
  end

  it 'should insert "_" for the fourth time.'
    execute 'normal' "o_\<Plug>(r)_\<Plug>(r)_\<Plug>(r)_"
    Expect getline('.') ==# ' <- '
  end

  it 'should insert " <- " for the fourth time.'
    execute 'normal' "o_\<Plug>(r)_\<Plug>(r)_\<Plug>(r)_\<Plug>(r)_"
    Expect getline('.') ==# ' <<< '
  end
end




describe 'smartchr_loop__with_ctype'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    cnoremap <expr> _  smartchr#loop(' <- ', ' <<< ', '_', {'ctype': '/'})
    new
  end

  after
    cunmap _
    quit!
  end

  it 'should be disabled for non-"/" Command-line mode, if ctype = "/".'
    execute 'silent' 'normal' ":let b:result = '_,__,___,____'\<Return>"
    Expect b:result ==# '_,__,___,____'
  end

  it 'should be enabled for "/" Command-line mode, if ctype = "/".'
    execute 'silent!' 'normal' "/_,__,___,____\<Return>"
    Expect @/ ==# ' <- , <<< ,_, <- '
  end
end




describe 'smartchr_loop__with_ctype_and_fallback'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    cnoremap <expr> _
    \ smartchr#loop(' <- ', ' <<< ', '_', {'ctype': '/', 'fallback': 'X'})
    new
  end

  after
    cunmap _
    quit!
  end

  it 'should use "fallback" instead of literal{N} if smartchr is disabled.'
    execute 'silent' 'normal' ":let b:result = '_,__,___,____'\<Return>"
    Expect b:result ==# 'X,XX,XXX,XXXX'
  end

  it 'should not use "fallback" if smartchr is enabled.'
    execute 'silent!' 'normal' "/_,__,___,____\<Return>"
    Expect @/ ==# ' <- , <<< ,_, <- '
  end
end




describe 'smartchr_loop__with_empty_context'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    cnoremap <expr> _  smartchr#loop(' <- ', ' <<< ', {})
    new
  end

  after
    cunmap _
    quit!
  end

  it 'should insert " <- " for the first time. (loop #1)'
    silent execute 'normal' ":let b:result = '_'\<Return>"
    Expect b:result ==# ' <- '
  end

  it 'should insert " <<< " for the second time. (loop #1)'
    silent execute 'normal' ":let b:result = '__'\<Return>"
    Expect b:result ==# ' <<< '
  end

  it 'should insert " <- " for the third time. (loop #2)'
    silent execute 'normal' ":let b:result = '___'\<Return>"
    Expect b:result ==# ' <- '
  end

  it 'should insert " <<< " for the fourth time. (loop #2)'
    silent execute 'normal' ":let b:result = '____'\<Return>"
    Expect b:result ==# ' <<< '
  end
end




describe 'smartchr_one_of__in_Command_line_mode'
  " BUGS: This test assumes that all keys but "_" will never be remapped.

  before
    cnoremap <expr> _  smartchr#one_of(' <- ', ' <<< ', '_')
    new
  end

  it 'should insert " <- " for the first time.'
    silent execute 'normal' ":let b:result = '_'\<Return>"
    Expect b:result ==# ' <- '
  end

  it 'should insert " <<< " for the second time.'
    silent execute 'normal' ":let b:result = '__'\<Return>"
    Expect b:result ==# ' <<< '
  end

  it 'should insert "_" for the third time.'
    silent execute 'normal' ":let b:result = '___'\<Return>"
    Expect b:result ==# '_'
  end

  it 'should insert " <- " for the first time. (edge case)'
    silent execute 'normal' ":_\<Home>let b:result = '\<End>'\<Return>"
    Expect b:result ==# ' <- '
  end

  after
    cunmap _
    quit!
  end
end




describe 'smartchr_one_of__in_Insert_mode'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    inoremap <expr> _  smartchr#one_of(' <- ', ' <<< ', '_')
    new
  end

  it 'should insert " <- " for the first time.'
    execute 'normal' "o_"
    Expect getline('.') ==# ' <- '
  end

  it 'should insert " <<< " for the second time.'
    execute 'normal' "o_\<Plug>(r)_"
    Expect getline('.') ==# ' <<< '
  end

  it 'should insert "_" for the third time.'
    execute 'normal' "o_\<Plug>(r)_\<Plug>(r)_"
    Expect getline('.') ==# '_'
  end

  it 'should insert " <- _" for the fourth time.'
    execute 'normal' "o_\<Plug>(r)_\<Plug>(r)_\<Plug>(r)_"
    Expect getline('.') ==# '_ <- '
  end

  after
    iunmap _
    quit!
  end
end




describe 'smartchr_one_of__with_ctype'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    cnoremap <expr> _  smartchr#one_of(' <- ', ' <<< ', '_', {'ctype': '/'})
    new
  end

  it 'should be disabled for non-"/" Command-line mode, if ctype = "/".'
    execute 'silent' 'normal' ":let b:result = '_,__,___,____'\<Return>"
    Expect b:result ==# '_,__,___,____'
  end

  it 'should be enabled for "/" Command-line mode, if ctype = "/".'
    execute 'silent!' 'normal' "/_,__,___,____\<Return>"
    Expect @/ ==# ' <- , <<< ,_,_ <- '
  end

  after
    cunmap _
    quit!
  end
end




describe 'smartchr_one_of__with_ctype_and_fallback'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    cnoremap <expr> _
    \ smartchr#one_of(' <- ', ' <<< ', '_', {'ctype': '/', 'fallback': 'X'})
    new
  end

  it 'should use "fallback" instead of literal{N} if smartchr is disabled.'
    execute 'silent' 'normal' ":let b:result = '_,__,___,____'\<Return>"
    Expect b:result ==# 'X,XX,XXX,XXXX'
  end

  it 'should not use "fallback" if smartchr is enabled.'
    execute 'silent!' 'normal' "/_,__,___,____\<Return>"
    Expect @/ ==# ' <- , <<< ,_,_ <- '
  end

  after
    cunmap _
    quit!
  end
end




describe 'smartchr_one_of__with_empty_context'
  " BUGS: Assumption: all keys but "_" / "<Plug>(r)" will never be remapped.

  before
    cnoremap <expr> _  smartchr#one_of(' <- ', ' <<< ', '_', {})
    new
  end

  it 'should insert " <- " for the first time.'
    silent execute 'normal' ":let b:result = '_'\<Return>"
    Expect b:result ==# ' <- '
  end

  it 'should insert " <<< " for the second time.'
    silent execute 'normal' ":let b:result = '__'\<Return>"
    Expect b:result ==# ' <<< '
  end

  it 'should insert "_" for the third time.'
    silent execute 'normal' ":let b:result = '___'\<Return>"
    Expect b:result ==# '_'
  end

  it 'should insert " <- " for the first time. (edge case)'
    silent execute 'normal' ":_\<Home>let b:result = '\<End>'\<Return>"
    Expect b:result ==# ' <- '
  end

  after
    cunmap _
    quit!
  end
end
