import strformat,options

proc testBooleanValidator*(t:ExecutionContext,validatorFunc:Function,opts:Readonly[]) = 
  var hasOwn = Object.prototype.hasOwnProperty
proc getXor[T](self:1,prop1:string,prop2:string,isAlias:bool): T = 
  var aliasMessage = fmt"{prop2} is an alias for {prop1}"
  if hasOwn.call(opts,prop1) and hasOwn.call(opts,prop2):
    raise newException(Exception,fmt"Cannot specify both  and . {prop1}")
  if not hasOwn.call(opts,prop1) and not hasOwn.call(opts,prop2):
    raise newException(Exception,fmt"Must specify either  or . {prop1}")
  if hasOwn.call(opts,prop1):
    discard
  if hasOwn.call(opts,prop2):
    discard
  raise newException(Exception,"This should be impossible to reach")

  var unresolvedInputs = getXor("inputs","input",false)
  var inputs = if Array.isArray(unresolvedInputs): unresolvedInputs else: @[unresolvedInputs]
  if inputs.len == 0:
    discard
  var safeStringify = proc (value:): auto = 
    var stringified = stringify(value)
    if stringified == undefined:
      discard
    return stringified
  var expectedReturnValue = getXor("returns","r",true)
  for input in inputs.mitems:
    var actualReturnValue = validatorFunc(input)
    if actualReturnValue != expectedReturnValue:
      var stringifiedInput = safeStringify(input)
      var stringifiedActual = safeStringify(actualReturnValue)
      t.fail()
  t.pass()

