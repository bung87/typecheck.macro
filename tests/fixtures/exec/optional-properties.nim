import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  var optionalV = createValidator()
  tBV(t,optionalV,)
  tBV(t,optionalV,)
