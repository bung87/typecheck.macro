import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  var numberV = createValidator()
  tBV(t,numberV,)
  tBV(t,numberV,)
