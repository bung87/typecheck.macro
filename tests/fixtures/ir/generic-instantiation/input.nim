import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
  register("T")
  createValidator()
  createValidator()
  return _dumpAllIR
