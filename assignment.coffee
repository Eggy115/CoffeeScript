# Assignment
# ----------

# * Assignment
# * Compound Assignment
# * Destructuring Assignment
# * Context Property (@) Assignment
# * Existential Assignment (?=)
# * Assignment to variables similar to generated variables

test "context property assignment (using @)", ->
  nonce = {}
  addMethod = ->
    @method = -> nonce
    this
  eq nonce, addMethod.call({}).method()

test "unassignable values", ->
  nonce = {}
  for nonref in ['', '""', '0', 'f()'].concat CoffeeScript.RESERVED
    eq nonce, (try CoffeeScript.compile "#{nonref} = v" catch e then nonce)

# Compound Assignment

test "boolean operators", ->
  nonce = {}

  a  = 0
  a or= nonce
  eq nonce, a

  b  = 1
  b or= nonce
  eq 1, b

  c = 0
  c and= nonce
  eq 0, c

  d = 1
  d and= nonce
  eq nonce, d

  # ensure that RHS is treated as a group
  e = f = false
  e and= f or true
  eq false, e

test "compound assignment as a sub expression", ->
  [a, b, c] = [1, 2, 3]
  eq 6, (a + b += c)
  eq 1, a
  eq 5, b
  eq 3, c

# *note: this test could still use refactoring*
test "compound assignment should be careful about caching variables", ->
  count = 0
  list = []

  list[++count] or= 1
  eq 1, list[1]
  eq 1, count

  list[++count] ?= 2
  eq 2, list[2]
  eq 2, count

  list[count++] and= 6
  eq 6, list[2]
  eq 3, count

  base = ->
    ++count
    base

  base().four or= 4
  eq 4, base.four
  eq 4, count

  base().five ?= 5
  eq 5, base.five
  eq 5, count

  eq 5, base().five ?= 6
  eq 6, count

test "compound assignment with implicit objects", ->
  obj = undefined
  obj ?=
    one: 1

  eq 1, obj.one

  obj and=
    two: 2

  eq undefined, obj.one
  eq         2, obj.two

test "compound assignment (math operators)", ->
  num = 10
  num -= 5
  eq 5, num

  num *= 10
  eq 50, num

  num /= 10
  eq 5, num

  num %= 3
  eq 2, num

test "more compound assignment", ->
  a = {}
  val = undefined
  val ||= a
  val ||= true
  eq a, val

  b = {}
  val &&= true
  eq val, true
  val &&= b
  eq b, val

  c = {}
  val = null
  val ?= c
  val ?= true
  eq c, val

test "#1192: assignment starting with object literals", ->
  doesNotThrow (-> CoffeeScript.run "{}.p = 0")
  doesNotThrow (-> CoffeeScript.run "{}.p++")
  doesNotThrow (-> CoffeeScript.run "{}[0] = 1")
  doesNotThrow (-> CoffeeScript.run """{a: 1, 'b', "#{1}": 2}.p = 0""")
  doesNotThrow (-> CoffeeScript.run "{a:{0:{}}}.a[0] = 0")


# Destructuring Assignment

test "empty destructuring assignment", ->
  {} = {}
  [] = []

test "chained destructuring assignments", ->
  [a] = {0: b} = {'0': c} = [nonce={}]
  eq nonce, a
  eq nonce, b
  eq nonce, c

test "variable swapping to verify caching of RHS values when appropriate", ->
  a = nonceA = {}
  b = nonceB = {}
  c = nonceC = {}
  [a, b, c] = [b, c, a]
  eq nonceB, a
  eq nonceC, b
  eq nonceA, c
  [a, b, c] = [b, c, a]
  eq nonceC, a
  eq nonceA, b
  eq nonceB, c
  fn = ->
    [a, b, c] = [b, c, a]
  arrayEq [nonceA,nonceB,nonceC], fn()
  eq nonceA, a
  eq nonceB, b
  eq nonceC, c

test "#713: destructuring assignment should return right-hand-side value", ->
  nonces = [nonceA={},nonceB={}]
  eq nonces, [a, b] = [c, d] = nonces
  eq nonceA, a
  eq nonceA, c
  eq nonceB, b
  eq nonceB, d

test "#4787 destructuring of objects within arrays", ->
  arr = [1, {a:1, b:2}]
  [...,{a, b}] = arr
  eq a, 1
  eq b, arr[1].b
  deepEqual {a, b}, arr[1]

test "destructuring assignment with splats", ->
  a = {}; b = {}; c = {}; d = {}; e = {}
  [x,y...,z] = [a,b,c,d,e]
  eq a, x
  arrayEq [b,c,d], y
  eq e, z

  # Should not trigger implicit call, e.g. rest ... => rest(...)
  [x,y ...,z] = [a,b,c,d,e]
  eq a, x
  arrayEq [b,c,d], y
  eq e, z

test "deep destructuring assignment with splats", ->
  a={}; b={}; c={}; d={}; e={}; f={}; g={}; h={}; i={}
  [u, [v, w..., x], y..., z] = [a, [b, c, d, e], f, g, h, i]
  eq a, u
  eq b, v
  arrayEq [c,d], w
  eq e, x
  arrayEq [f,g,h], y
  eq i, z

test "destructuring assignment with objects", ->
  a={}; b={}; c={}
  obj = {a,b,c}
  {a:x, b:y, c:z} = obj
  eq a, x
  eq b, y
  eq c, z

test "deep destructuring assignment with objects", ->
  a={}; b={}; c={}; d={}
  obj = {
    a
    b: {
      'c': {
        d: [
          b
          {e: c, f: d}
        ]
      }
    }
  }
  {a: w, 'b': {c: d: [x, {'f': z, e: y}]}} = obj
  eq a, w
  eq b, x
  eq c, y
  eq d, z

test "destructuring assignment with objects and splats", ->
  a={}; b={}; c={}; d={}
  obj = a: b: [a, b, c, d]
  {a: b: [y, z...]} = obj
  eq a, y
  arrayEq [b,c,d], z

  # Should not trigger implicit call, e.g. rest ... => rest(...)
  {a: b: [y, z ...]} = obj
  eq a, y
  arrayEq [b,c,d], z

test "destructuring assignment against an expression", ->
  a={}; b={}
  [y, z] = if true then [a, b] else [b, a]
  eq a, y
  eq b, z

test "bracket insertion when necessary", ->
  [a] = [0] ? [1]
  eq a, 0

# for implicit destructuring assignment in comprehensions, see the comprehension tests

test "destructuring assignment with context (@) properties", ->
  a={}; b={}; c={}; d={}; e={}
  obj =
    fn: () ->
      local = [a, {b, c}, d, e]
      [@a, {b: @b, c: @c}, @d, @e] = local
  eq undefined, obj[key] for key in ['a','b','c','d','e']
  obj.fn()
  eq a, obj.a
  eq b, obj.b
  eq c, obj.c
  eq d, obj.d
  eq e, obj.e

test "#1024: destructure empty assignments to produce javascript-like results", ->
  eq 2 * [] = 3 + 5, 16

test "#1005: invalid identifiers allowed on LHS of destructuring assignment", ->
  disallowed = ['eval', 'arguments'].concat CoffeeScript.RESERVED
  throwsCompileError "[#{disallowed.join ', '}] = x", null, null, 'all disallowed'
  throwsCompileError "[#{disallowed.join '..., '}...] = x", null, null, 'all disallowed as splats'
  t = tSplat = null
  for v in disallowed when v isnt 'class' # `class` by itself is an expression
    throwsCompileError t, null, null, t = "[#{v}] = x"
    throwsCompileError tSplat, null, null, tSplat = "[#{v}...] = x"
  for v in disallowed
    doesNotThrowCompileError "[a.#{v}] = x"
    doesNotThrowCompileError "[a.#{v}...] = x"
    doesNotThrowCompileError "[@#{v}] = x"
    doesNotThrowCompileError "[@#{v}...] = x"

test "#2055: destructuring assignment with `new`", ->
  {length} = new Array
  eq 0, length

test "#156: destructuring with expansion", ->
  array = [1..5]
  [first, ..., last] = array
  eq 1, first
  eq 5, last
  [..., lastButOne, last] = array
  eq 4, lastButOne
  eq 5, last
  [first, second, ..., last] = array
  eq 2, second
  [..., last] = 'strings as well -> x'
  eq 'x', last
  throwsCompileError "[1, ..., 3]",        null, null, "prohibit expansion outside of assignment"
  throwsCompileError "[..., a, b...] = c", null, null, "prohibit expansion and a splat"
  throwsCompileError "[...] = c",          null, null, "prohibit lone expansion"

test "destructuring with dynamic keys", ->
  {"#{'a'}": a, """#{'b'}""": b, c} = {a: 1, b: 2, c: 3}
  eq 1, a
  eq 2, b
  eq 3, c
  throwsCompileError '{"#{a}"} = b'

test "simple array destructuring defaults", ->
  [a = 1] = []
  eq 1, a
  [a = 2] = [undefined]
  eq 2, a
  [a = 3] = [null]
  eq null, a # Breaking change in CS2: per ES2015, default values are applied for `undefined` but not for `null`.
  [a = 4] = [0]
  eq 0, a
  arr = [a = 5]
  eq 5, a
  arrayEq [5], arr

test "simple object destructuring defaults", ->
  {b = 1} = {}
  eq b, 1
  {b = 2} = {b: undefined}
  eq b, 2
  {b = 3} = {b: null}
  eq b, null # Breaking change in CS2: per ES2015, default values are applied for `undefined` but not for `null`.
  {b = 4} = {b: 0}
  eq b, 0

  {b: c = 1} = {}
  eq c, 1
  {b: c = 2} = {b: undefined}
  eq c, 2
  {b: c = 3} = {b: null}
  eq c, null # Breaking change in CS2: per ES2015, default values are applied for `undefined` but not for `null`.
  {b: c = 4} = {b: 0}
  eq c, 0

test "multiple array destructuring defaults", ->
  [a = 1, b = 2, c] = [undefined, 12, 13]
  eq a, 1
  eq b, 12
  eq c, 13
  [a, b = 2, c = 3] = [undefined, 12, 13]
  eq a, undefined
  eq b, 12
  eq c, 13
  [a = 1, b, c = 3] = [11, 12]
  eq a, 11
  eq b, 12
  eq c, 3

test "multiple object destructuring defaults", ->
  {a = 1, b: bb = 2, 'c': c = 3, "#{0}": d = 4} = {"#{'b'}": 12}
  eq a, 1
  eq bb, 12
  eq c, 3
  eq d, 4

test "array destructuring defaults with splats", ->
  [..., a = 9] = []
  eq a, 9
  [..., b = 9] = [19]
  eq b, 19

test "deep destructuring assignment with defaults", ->
  [a, [{b = 1, c = 3}] = [c: 2]] = [0]
  eq a, 0
  eq b, 1
  eq c, 2

test "destructuring assignment with context (@) properties and defaults", ->
  a={}; b={}; c={}; d={}; e={}
  obj =
    fn: () ->
      local = [a, {b, c: undefined}, d]
      [@a, {b: @b = b, @c = c}, @d, @e = e] = local
  eq undefined, obj[key] for key in ['a','b','c','d','e']
  obj.fn()
  eq a, obj.a
  eq b, obj.b
  eq c, obj.c
  eq d, obj.d
  eq e, obj.e

test "destructuring assignment with defaults single evaluation", ->
  callCount = 0
  fn = -> callCount++
  [a = fn()] = []
  eq 0, a
  eq 1, callCount
  [a = fn()] = [10]
  eq 10, a
  eq 1, callCount
  {a = fn(), b: c = fn()} = {a: 20, b: undefined}
  eq 20, a
  eq c, 1
  eq callCount, 2


# Existential Assignment

test "existential assignment", ->
  nonce = {}
  a = false
  a ?= nonce
  eq false, a
  b = undefined
  b ?= nonce
  eq nonce, b
  c = null
  c ?= nonce
  eq nonce, c

test "#1627: prohibit conditional assignment of undefined variables", ->
  throwsCompileError "x ?= 10",        null, null, "prohibit (x ?= 10)"
  throwsCompileError "x ||= 10",       null, null, "prohibit (x ||= 10)"
  throwsCompileError "x or= 10",       null, null, "prohibit (x or= 10)"
  throwsCompileError "do -> x ?= 10",  null, null, "prohibit (do -> x ?= 10)"
  throwsCompileError "do -> x ||= 10", null, null, "prohibit (do -> x ||= 10)"
  throwsCompileError "do -> x or= 10", null, null, "prohibit (do -> x or= 10)"
  doesNotThrowCompileError "x = null; x ?= 10",        null, "allow (x = null; x ?= 10)"
  doesNotThrowCompileError "x = null; x ||= 10",       null, "allow (x = null; x ||= 10)"
  doesNotThrowCompileError "x = null; x or= 10",       null, "allow (x = null; x or= 10)"
  doesNotThrowCompileError "x = null; do -> x ?= 10",  null, "allow (x = null; do -> x ?= 10)"
  doesNotThrowCompileError "x = null; do -> x ||= 10", null, "allow (x = null; do -> x ||= 10)"
  doesNotThrowCompileError "x = null; do -> x or= 10", null, "allow (x = null; do -> x or= 10)"

  throwsCompileError "-> -> -> x ?= 10", null, null, "prohibit (-> -> -> x ?= 10)"
  doesNotThrowCompileError "x = null; -> -> -> x ?= 10", null, "allow (x = null; -> -> -> x ?= 10)"

test "more existential assignment", ->
  global.temp ?= 0
  eq global.temp, 0
  global.temp or= 100
  eq global.temp, 100
  delete global.temp

test "#1348, #1216: existential assignment compilation", ->
  nonce = {}
  a = nonce
  b = (a ?= 0)
  eq nonce, b
  #the first ?= compiles into a statement; the second ?= compiles to a ternary expression
  eq a ?= b ?= 1, nonce

  if a then a ?= 2 else a = 3
  eq a, nonce

test "#1591, #1101: splatted expressions in destructuring assignment must be assignable", ->
  nonce = {}
  for nonref in ['', '""', '0', 'f()', '(->)'].concat CoffeeScript.RESERVED
    eq nonce, (try CoffeeScript.compile "[#{nonref}...] = v" catch e then nonce)

test "#1643: splatted accesses in destructuring assignments should not be declared as variables", ->
  nonce = {}
  accesses = ['o.a', 'o["a"]', '(o.a)', '(o.a).a', '@o.a', 'C::a', 'f().a', 'o?.a', 'o?.a.b', 'f?().a']
  for access in accesses
    for i,j in [1,2,3] #position can matter
      code =
        """
        nonce = {}; nonce2 = {}; nonce3 = {};
        @o = o = new (class C then a:{}); f = -> o
        [#{new Array(i).join('x,')}#{access}...] = [#{new Array(i).join('0,')}nonce, nonce2, nonce3]
        unless #{access}[0] is nonce and #{access}[1] is nonce2 and #{access}[2] is nonce3 then throw new Error('[...]')
        """
      eq nonce, unless (try CoffeeScript.run code, bare: true catch e then true) then nonce
  # subpatterns like `[[a]...]` and `[{a}...]`
  subpatterns = ['[sub, sub2, sub3]', '{0: sub, 1: sub2, 2: sub3}']
  for subpattern in subpatterns
    for i,j in [1,2,3]
      code =
        """
        nonce = {}; nonce2 = {}; nonce3 = {};
        [#{new Array(i).join('x,')}#{subpattern}...] = [#{new Array(i).join('0,')}nonce, nonce2, nonce3]
        unless sub is nonce and sub2 is nonce2 and sub3 is nonce3 then throw new Error('[sub...]')
        """
      eq nonce, unless (try CoffeeScript.run code, bare: true catch e then true) then nonce

test "#1838: Regression with variable assignment", ->
  name =
  'dave'

  eq name, 'dave'

test '#2211: splats in destructured parameters', ->
  doesNotThrowCompileError '([a...]) ->'
  doesNotThrowCompileError '([a...],b) ->'
  doesNotThrowCompileError '([a...],[b...]) ->'
  throwsCompileError '([a...,[a...]]) ->'
  doesNotThrowCompileError '([a...,[b...]]) ->'

test '#2213: invocations within destructured parameters', ->
  throwsCompileError '([a()])->'
  throwsCompileError '([a:b()])->'
  throwsCompileError '([a:b.c()])->'
  throwsCompileError '({a()})->'
  throwsCompileError '({a:b()})->'
  throwsCompileError '({a:b.c()})->'

test '#2532: compound assignment with terminator', ->
  doesNotThrowCompileError """
  a = "hello"
  a +=
  "
  world
  !
  "
  """

test "#2613: parens on LHS of destructuring", ->
  a = {}
  [(a).b] = [1, 2, 3]
  eq a.b, 1

test "#2181: conditional assignment as a subexpression", ->
  a = false
  false && a or= true
  eq false, a
  eq false, not a or= true

test "#1500: Assignment to variables similar to generated variables", ->
  len = 0
  x = ((results = null; n) for n in [1, 2, 3])
  arrayEq [1, 2, 3], x
  eq 0, len

  for x in [1, 2, 3]
    f = ->
      i = 0
    f()
    eq 'undefined', typeof i

  ref = 2
  x = ref * 2 ? 1
  eq x, 4
  eq 'undefined', typeof ref1

  x = {}
  base = -> x
  name = -1
  base()[-name] ?= 2
  eq x[1], 2
  eq base(), x
  eq name, -1

  f = (@a, a) -> [@a, a]
  arrayEq [1, 2], f.call scope = {}, 1, 2
  eq 1, scope.a

  try throw 'foo'
  catch error
    eq error, 'foo'

  eq error, 'foo'

  doesNotThrowCompileError '(@slice...) ->'

test "Assignment to variables similar to helper functions", ->
  f = (slice...) -> slice
  arrayEq [1, 2, 3], f 1, 2, 3
  eq 'undefined', typeof slice1

  class A
  class B extends A
    extend = 3
    hasProp = 4
    value: 5
    method: (bind, bind1) => [bind, bind1, extend, hasProp, @value]
  {method} = new B
  arrayEq [1, 2, 3, 4, 5], method 1, 2

  modulo = -1 %% 3
  eq 2, modulo

  indexOf = [1, 2, 3]
  ok 2 in indexOf

test "#4566: destructuring with nested default values", ->
  {a: {b = 1}} = a: {}
  eq 1, b

  {c: {d} = {}} = c: d: 3
  eq 3, d

  {e: {f = 5} = {}} = {}
  eq 5, f

test "#4878: Compile error when using destructuring with a splat or expansion in an array", ->
  arr = ['a', 'b', 'c', 'd']

  f1 = (list) ->
    [first, ..., last] = list

  f2 = (list) ->
    [first..., last] = list

  f3 = (list) ->
    ([first, ...] = list); first

  f4 = (list) ->
    ([first, rest...] = list); rest

  arrayEq f1(arr), arr
  arrayEq f2(arr), arr
  arrayEq f3(arr), 'a'
  arrayEq f4(arr), ['b', 'c', 'd']

  foo = (list) ->
    ret =
      if list?.length > 0
        [first, ..., last] = list
        [first, last]
      else
        []

  arrayEq foo(arr), ['a', 'd']

  bar = (list) ->
    ret =
      if list?.length > 0
        [first, rest...] = list
        [first, rest]
      else
        []

  arrayEq bar(arr), ['a', ['b', 'c', 'd']]

test "destructuring assignment with an empty array in object", ->
  obj =
    a1: [1, 2]
    b1: 3

  {a1:[], b1} = obj
  eq 'undefined', typeof a1
  eq b1, 3

  obj =
    a2:
      b2: [1, 2]
    c2: 3

  {a2: {b2:[]}, c2} = obj
  eq 'undefined', typeof b2
  eq c2, 3

test "#5004: array destructuring with accessors", ->
  obj =
    arr: ['a', 'b', 'c', 'd']
    list: {}
    f1: ->
      [@first, @rest...] = @arr
    f2: ->
      [@second, @third..., @last] = @rest
    f3: ->
      [@list.a, @list.middle..., @list.d] = @arr

  obj.f1()
  eq obj.first, 'a'
  arrayEq obj.rest, ['b', 'c', 'd']

  obj.f2()
  eq obj.second, 'b'
  arrayEq obj.third, ['c']
  eq obj.last, 'd'

  obj.f3()
  eq obj.list.a, 'a'
  arrayEq obj.list.middle, ['b', 'c']
  eq obj.list.d, 'd'

  [obj.list.middle..., d] = obj.arr
  eq d, 'd'
  arrayEq obj.list.middle, ['a', 'b', 'c']

test "#4884: destructured object splat", ->
  [{length}...] = [1, 2, 3]
  eq length, 3
  [{length: len}...] = [1, 2, 3]
  eq len, 3
  [{length}..., three] = [1, 2, 3]
  eq length, 2
  eq three, 3
  [{length: len}..., three] = [1, 2, 3]
  eq len, 2
  eq three, 3
  x = [{length}..., three] = [1, 2, 3]
  eq length, 2
  eq three, 3
  eq x[2], 3
  x = [{length: len}..., three] = [1, 2, 3]
  eq len, 2
  eq three, 3
  eq x[2], 3

test "#4884: destructured array splat", ->
  [[one, two, three]...] = [1, 2, 3]
  eq one, 1
  eq two, 2
  eq three, 3
  [[one, two]..., three] = [1, 2, 3]
  eq one, 1
  eq two, 2
  eq three, 3
  x = [[one, two]..., three] = [1, 2, 3]
  eq one, 1
  eq two, 2
  eq three, 3
  eq x[2], 3
