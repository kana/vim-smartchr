set backspace=indent,eol,start
set encoding=utf-8
set fileencoding=utf-8
scriptencoding utf-8

describe 'vim-smartchr'
  before
    new
  end

  after
    close!
  end

  it 'handles multibyte characters correctly'
    inoremap <buffer> <expr> ø smartchr#loop('ø', '\oo')

    normal! i123
    Expect getline('.') ==# '123'

    normal Aø
    Expect getline('.') ==# '123ø'

    normal Aø
    Expect getline('.') ==# '123\oo'

    normal Aø
    Expect getline('.') ==# '123ø'

    normal Aø
    Expect getline('.') ==# '123\oo'
  end
end
