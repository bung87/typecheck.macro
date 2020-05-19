import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
type Generic* = ref object of RootObj
  a*:Record[string,Record[float,Z]]


type Bar* = ref object of RootObj


type Foo* = ref object of RootObj


  register("Generic")
  register("Foo")
  return _dumpAllIR
