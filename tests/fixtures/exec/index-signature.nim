import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  var indexV = createValidator()
  tBV(t,indexV,)
  tBV(t,indexV,)
