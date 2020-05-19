import strformat,options

import ../../../../dist/typecheck.macro
proc (): auto = 
type LiteralType* = ref object of RootObj
  hello*:"world"
  foo*:42
  bar*:true


  register("LiteralType")
  return _dumpAllIR
