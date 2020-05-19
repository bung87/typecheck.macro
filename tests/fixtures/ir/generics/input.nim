import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
type G1* = ref object of RootObj
  a*:X


  register("G1")
  register("G2")
  return _dumpAllIR
