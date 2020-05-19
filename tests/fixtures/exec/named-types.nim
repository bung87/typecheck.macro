import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
type Foo* = ref object of RootObj
  val*:string


  register("Foo")
  var namedTypeV = createValidator()
  tBV(t,namedTypeV,)
  tBV(t,namedTypeV,)
