import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
type foo* = ref object of RootObj


  register("Empty")
  register("NoOptional")
  register("Optional")
  register("Rest")
  return _dumpAllIR
