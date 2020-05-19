import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
type Foo* = ref object of RootObj
  foo*:string


type Bar* = ref object of RootObj
  bar*:Foo


  register("Bar")
  return _dumpAllIR
