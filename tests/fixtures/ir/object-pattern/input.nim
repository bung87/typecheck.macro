import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
  register("T")
  return _dumpAllIR
