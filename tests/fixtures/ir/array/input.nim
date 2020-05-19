import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
  register("Type")
  register("ReadonlyType")
  register("Literal")
  return _dumpAllIR
