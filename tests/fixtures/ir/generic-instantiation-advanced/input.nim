import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
  register("T2")
  register("Foo")
  createValidator()
  return _dumpAllIR
