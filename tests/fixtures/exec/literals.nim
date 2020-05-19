import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  var helloV = createValidator()
  var weirdString = "he\"l''l\no"
  var sixsixsixV = createValidator()
  var falseV = createValidator()
  tBV(t,helloV,)
  tBV(t,helloV,)
  tBV(t,sixsixsixV,)
  tBV(t,sixsixsixV,)
  tBV(t,falseV,)
  tBV(t,falseV,)
