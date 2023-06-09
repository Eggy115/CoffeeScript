# String Literals
# ---------------

# TODO: refactor string literal tests
# TODO: add indexing and method invocation tests: "string"["toString"] is String::toString, "string".toString() is "string"

# * Strings
# * Heredocs

test "backslash escapes", ->
  eq "\\/\\\\", /\/\\/.source

eq '(((dollars)))', '\(\(\(dollars\)\)\)'
eq 'one two three', "one
 two
 three"
eq "four five", 'four

 five'

test "#3229, multiline strings", ->
  # Separate lines by default by a single space in literal strings.
  eq 'one
      two', 'one two'
  eq "one
      two", 'one two'
  eq '
        a
        b
    ', 'a b'
  eq "
        a
        b
    ", 'a b'
  eq 'one

        two', 'one two'
  eq "one

        two", 'one two'
  eq '
    indentation
      doesn\'t
  matter', 'indentation doesn\'t matter'
  eq 'trailing ws      
    doesn\'t matter', 'trailing ws doesn\'t matter'

  # Use backslashes at the end of a line to specify whitespace between lines.
  eq 'a \
      b\
      c  \
      d', 'a bc  d'
  eq "a \
      b\
      c  \
      d", 'a bc  d'
  eq 'ignore  \  
      trailing whitespace', 'ignore  trailing whitespace'

  # Backslash at the beginning of a literal string.
  eq '\
      ok', 'ok'
  eq '  \
      ok', '  ok'

  # #1273, empty strings.
  eq '\
     ', ''
  eq '
     ', ''
  eq '
          ', ''
  eq '   ', '   '

  # Same behavior in interpolated strings.
  eq "interpolation #{1}
      follows #{2}  \
      too #{3}\
      !", 'interpolation 1 follows 2  too 3!'
  eq "a #{
    'string ' + "inside
                 interpolation"
    }", "a string inside interpolation"
  eq "
      #{1}
     ", '1'

  # Handle escaped backslashes correctly.
  eq '\\', `'\\'`
  eq 'escaped backslash at EOL\\
      next line', 'escaped backslash at EOL\\ next line'
  eq '\\
      next line', '\\ next line'
  eq '\\
     ', '\\'
  eq '\\\\\\
     ', '\\\\\\'
  eq "#{1}\\
      after interpolation", '1\\ after interpolation'
  eq 'escaped backslash before slash\\  \
      next line', 'escaped backslash before slash\\  next line'
  eq 'triple backslash\\\
      next line', 'triple backslash\\next line'
  eq 'several escaped backslashes\\\\\\
      ok', 'several escaped backslashes\\\\\\ ok'
  eq 'several escaped backslashes slash\\\\\\\
      ok', 'several escaped backslashes slash\\\\\\ok'
  eq 'several escaped backslashes with trailing ws \\\\\\   
      ok', 'several escaped backslashes with trailing ws \\\\\\ ok'

  # Backslashes at beginning of lines.
  eq 'first line
      \   backslash at BOL', 'first line \   backslash at BOL'
  eq 'first line\
      \   backslash at BOL', 'first line\   backslash at BOL'

  # Backslashes at end of strings.
  eq 'first line \ ', 'first line  '
  eq 'first line
      second line \
      ', 'first line second line '
  eq 'first line
      second line
      \
      ', 'first line second line'
  eq 'first line
      second line

        \

      ', 'first line second line'

  # Edge case.
  eq 'lone

        \

        backslash', 'lone backslash'

test "#3249, escape newlines in heredocs with backslashes", ->
  # Ignore escaped newlines
  eq '''
    Set whitespace      \
       <- this is ignored\  
           none
      normal indentation
    ''', 'Set whitespace      <- this is ignorednone\n  normal indentation'
  eq """
    Set whitespace      \
       <- this is ignored\  
           none
      normal indentation
    """, 'Set whitespace      <- this is ignorednone\n  normal indentation'

  # Changed from #647, trailing backslash.
  eq '''
  Hello, World\

  ''', 'Hello, World'
  eq '''
    \\
  ''', '\\'

  # Backslash at the beginning of a literal string.
  eq '''\
      ok''', 'ok'
  eq '''  \
      ok''', '  ok'

  # Same behavior in interpolated strings.
  eq """
    interpolation #{1}
      follows #{2}  \
        too #{3}\
    !
  """, 'interpolation 1\n  follows 2  too 3!'
  eq """

    #{1} #{2}

    """, '\n1 2\n'

  # Handle escaped backslashes correctly.
  eq '''
    escaped backslash at EOL\\
      next line
  ''', 'escaped backslash at EOL\\\n  next line'
  eq '''\\

     ''', '\\\n'

  # Backslashes at beginning of lines.
  eq '''first line
      \   backslash at BOL''', 'first line\n\   backslash at BOL'
  eq """first line\
      \   backslash at BOL""", 'first line\   backslash at BOL'

  # Backslashes at end of strings.
  eq '''first line \ ''', 'first line  '
  eq '''
    first line
    second line \
  ''', 'first line\nsecond line '
  eq '''
    first line
    second line
    \
  ''', 'first line\nsecond line'
  eq '''
    first line
    second line

      \

  ''', 'first line\nsecond line\n'

  # Edge cases.
  eq '''lone

          \



        backslash''', 'lone\n\n  backslash'
  eq '''\
     ''', ''

test '#2388: `"""` in heredoc interpolations', ->
  eq """a heredoc #{
      "inside \
        interpolation"
    }""", "a heredoc inside interpolation"
  eq """a#{"""b"""}c""", 'abc'
  eq """#{""""""}""", ''

test "trailing whitespace", ->
  testTrailing = (str, expected) ->
    eq CoffeeScript.eval(str.replace /\|$/gm, ''), expected
  testTrailing '''"   |
      |
    a   |
           |
  "''', 'a'
  testTrailing """'''   |
      |
    a   |
           |
  '''""", '  \na   \n       '

#647
eq "''Hello, World\\''", '''
'\'Hello, World\\\''
'''
eq '""Hello, World\\""', """
"\"Hello, World\\\""
"""

test "#1273, escaping quotes at the end of heredocs.", ->
  # """\""" no longer compiles
  eq """\\""", '\\'
  eq """\\\"""", '\\\"'

a = """
    basic heredoc
    on two lines
    """
ok a is "basic heredoc\non two lines"

a = '''
    a
      "b
    c
    '''
ok a is "a\n  \"b\nc"

a = """
a
 b
  c
"""
ok a is "a\n b\n  c"

a = '''one-liner'''
ok a is 'one-liner'

a = """
      out
      here
"""
ok a is "out\nhere"

a = '''
       a
     b
   c
    '''
ok a is "    a\n  b\nc"

a = '''
a


b c
'''
ok a is "a\n\n\nb c"

a = '''more"than"one"quote'''
ok a is 'more"than"one"quote'

a = '''here's an apostrophe'''
ok a is "here's an apostrophe"

a = """""surrounded by two quotes"\""""
ok a is '""surrounded by two quotes""'

a = '''''surrounded by two apostrophes'\''''
ok a is "''surrounded by two apostrophes''"

# The indentation detector ignores blank lines without trailing whitespace
a = """
    one
    two

    """
ok a is "one\ntwo\n"

eq ''' line 0
  should not be relevant
    to the indent level
''', ' line 0\nshould not be relevant\n  to the indent level'

eq """
  interpolation #{
 "contents"
 }
  should not be relevant
    to the indent level
""", 'interpolation contents\nshould not be relevant\n  to the indent level'

eq ''' '\\\' ''', " '\\' "
eq """ "\\\" """, ' "\\" '

eq '''  <- keep these spaces ->  ''', '  <- keep these spaces ->  '

eq '''undefined''', 'undefined'
eq """undefined""", 'undefined'


test "#1046, empty string interpolations", ->
  eq "#{ }", ''

test "strings are not callable", ->
  throwsCompileError '"a"()'
  throwsCompileError '"a#{b}"()'
  throwsCompileError '"a" 1'
  throwsCompileError '"a#{b}" 1'
  throwsCompileError '''
    "a"
       k: v
  '''
  throwsCompileError '''
    "a#{b}"
       k: v
  '''

test "#3795: Escape otherwise invalid characters", ->
  eq ' ', '\u2028'
  eq ' ', '\u2029'
  eq '\0\
      1', '\x001'
  eq " ", '\u2028'
  eq " ", '\u2029'
  eq "\0\
      1", '\x001'
  eq "\0\
      9", '\x009'
  eq "\0#{}0", '\x000'
  eq ''' ''', '\u2028'
  eq ''' ''', '\u2029'
  eq '''\0\
      1''', '\x001'
  eq '''\0\
      9''', '\x009'
  eq """\0#{}1""", '\x001'
  eq """ """, '\u2028'
  eq """ """, '\u2029'
  eq """\0\
      1""", '\x001'

  a = 'a'
  eq "#{a} ", 'a\u2028'
  eq "#{a} ", 'a\u2029'
  eq "#{a}\0\
      1", 'a\0' + '1'
  eq """#{a} """, 'a\u2028'
  eq """#{a} """, 'a\u2029'
  eq """#{a}\0\
      1""", 'a\0' + '1'

test "#4314: Whitespace less than or equal to stripped indentation", ->
  # The odd indentation is intentional here, to test 1-space indentation.
  eq ' ', """
 #{} #{}
"""

  eq '1 2  3   4    5     end\na 0     b', """
    #{1} #{2}  #{3}   #{4}    #{5}     end
    a #{0}     b"""

test "#4248: Unicode code point escapes", ->
  eq '\u01ab\u00cd', '\u{1ab}\u{cd}'
  eq '\u01ab', '\u{000001ab}'
  eq 'a\u01ab', "#{ 'a' }\u{1ab}"
  eq '\u01abc', '''\u{01ab}c'''
  eq '\u01abc', """\u{1ab}#{ 'c' }"""
  eq '\udab3\uddef', '\u{bcdef}'
  eq '\udab3\uddef', '\u{0000bcdef}'
  eq 'a\udab3\uddef', "#{ 'a' }\u{bcdef}"
  eq '\udab3\uddefc', '''\u{0bcdef}c'''
  eq '\udab3\uddefc', """\u{bcdef}#{ 'c' }"""
  eq '\\u{123456}', "#{'\\'}#{'u{123456}'}"

  # don't rewrite code point escapes
  eqJS """
    '\\u{bcdef}\\u{abc}'
  """,
  """
    '\\u{bcdef}\\u{abc}';
  """

  eqJS """
    "#{ 'a' }\\u{bcdef}"
  """,
  """
    "a\\u{bcdef}";
  """
