import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  var basicV = createValidator()
  var complexV = createValidator()
  tBV(t,basicV,)
  tBV(t,basicV,)
  tBV(t,complexV,)
  tBV(t,complexV,)
