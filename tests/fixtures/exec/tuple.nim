import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
  var emptyTupleV = createValidator()
  tBV(t,emptyTupleV,)
  var basicTupleV = createValidator()
  tBV(t,basicTupleV,)
  tBV(t,basicTupleV,)
  var anyTupleV = createValidator()
  var partiallyEmptyArray = Array(3)
  partiallyEmptyArray[2] = 3
  tBV(t,anyTupleV,)
  tBV(t,anyTupleV,)
  var optionalTupleV = createValidator()
  tBV(t,optionalTupleV,)
  tBV(t,optionalTupleV,)
  var restTupleV = createValidator()
  tBV(t,restTupleV,)
  tBV(t,restTupleV,)
  var heterogeneousRestTupleV = createValidator()
  tBV(t,heterogeneousRestTupleV,)
