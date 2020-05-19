import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  register("T2")
  register("Foo")
  var validator = createValidator()
  tBV(t,validator,)
  tBV(t,validator,)
