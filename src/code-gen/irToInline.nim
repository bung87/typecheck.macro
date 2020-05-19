import strformat

import ../type-ir/typeIR
import ../macro-assertions
import ../utils/stringify
proc isInterface(ir:IR):  = 
  ir.type == "interface"

proc isTypeAlias(ir:IR):  = 
  ir.type == "alias"

proc isIR(val:any):  = 
  return Object.prototype.hasOwnProperty.call(val,"type") and typeof val.type == "string"

proc isGenericType(val:any):  = 
  return isIR(val) and val.type == "genericType"

type Ast = enum
  NONE, EXPR

type Validator* = ref object of RootObj
  type*:T
  code*:


## so make sure it doesn't have special characters
var TEMPLATE_VAR = "TEMPLATE"
var TEMPLATE_REGEXP = RegExp(TEMPLATE_VAR,"g")
var primitives:ReadonlyMap[PrimitiveTypeName,Readonly[Validator[]|Validator[]]] = Map(@[("any",),("unknown",),("null",),("undefined",),("boolean",),("number",),("string",),("object",)])
## Array is technically not a primitive type
var IS_ARRAY = fmt"!! && .constructor === Array"
type State* = ref object of RootObj
  namedTypes*:Map[string,IR]
  referencedTypeNames*:seq[string]
  parentParamIdx*:float  ## (we prefer an explicit crash in the validator, so the user of the library can report it)

  parentParamName*:string|  ## will have a parameter like p0



proc generateValidator(ir:IR,namedTypes:Map[string,IR]): string = 
var state:State = newState(referencedTypeNames= @[],parentParamIdx= 0,parentParamName= nil,namedTypes= namedTypes)  var validator = visitIR(ir,state)
  var paramName = getParam(state)
  if isNonEmptyValidator(validator):
    var code = validator.code

    return fmt"{paramName} => {code}"
  else:
    discard

proc visitIR(ir:IR,state:State): Validator[Ast] = 
  var visitorFunction:proc (ir:IR,state:State): auto 
  case ir.type:
    of "primitiveType":
      visitorFunction = visitPrimitiveType
    of "objectPattern":
      visitorFunction = visitObjectPattern
    of "type":
      visitorFunction = visitType
    of "arrayType":
      visitorFunction = visitArray
    of "union":
      visitorFunction = visitUnion
    of "tuple":
      visitorFunction = visitTuple
    of "literal":
      visitorFunction = visitLiteral
    else:
      throwUnexpectedError(fmt"unexpected ir type: {ir.type}")
  visitorFunction(ir,state)

proc wrapWithFunction(code:string,functionParamIdxOrName:float|string|,state:State): string = 
  var functionParam = if typeof functionParamIdxOrName == "string": functionParamIdxOrName else: if functionParamIdxOrName == nil: "" else: getFunctionParam(functionParamIdxOrName)
  return 

proc getFunctionParam(parentParamIdx:float): auto = 

proc getParam(:State): auto = 

proc template(code:string,name:string): auto = 

proc visitTuple(ir:Tuple,state:State): Validator[] = 
  var parameterName = getParam(state)
  var childTypes = ir.childTypes
  firstOptionalIndex = ir.firstOptionalIndex
  restType = ir.restType

  var lengthCheckCode = fmt"()"
  if firstOptionalIndex == childTypes.len:
    lengthCheckCode += fmt"&& .length = {parameterName}"
  elif restType:
    lengthCheckCode += fmt"&& .length >= {parameterName}"
  else:
    discard
  var verifyNonRestElementsCode = ""
  var i = 0
  while i < childTypes.len:
    ## Maybe with a switch? What we really need is goto...
    var arrayAccessCode = fmt"{parameterName}[]"
    var elementValidator = visitIR(childTypes[i],)
    if elementValidator.type == Ast.NONE:
      discard
    var code = elementValidator.code

    verifyNonRestElementsCode += " "
    if i < firstOptionalIndex:
      verifyNonRestElementsCode += fmt"&& {code}"
    else:
      discard
var noRestElementValidator:Validator[] = newValidator[](type= Ast.EXPR,code= fmt"{lengthCheckCode}{verifyNonRestElementsCode}{}")  if restType == undefined:
    return noRestElementValidator
  else:
    discard

proc visitLiteral(ir:Literal,state:State): Validator[] = 
  ## TODO: Once we add bigint support, this will need to be updated
  var resolvedParentParamName = getParam(state)
  var value = ir.value

  return 

proc visitUnion(ir:Union,state:State): Validator[|] = 
  var childTypeValidators:seq[Validator[]] = @[]
  for childType in undefined.mitems:
    var validator = visitIR(childType,state)
    if isNonEmptyValidator(validator):
      childTypeValidators.add(validator)
    else:
      discard
  var ifStmtConditionCode = ""
  for v in childTypeValidators.mitems:
    var code = v.code

    ifStmtConditionCode += if ifStmtConditionCode == "": code else: fmt"|| {code}"
  return 

proc visitArray(ir:ArrayType,state:State): Validator[] = 
  var parentParamIdx = state.parentParamIdx

  var parentParamName = getParam(state)
  var propertyVerifierParamIdx = parentParamIdx + 1
  var propertyVerifierParamName = getFunctionParam(propertyVerifierParamIdx)
  var loopElementIdx = propertyVerifierParamIdx + 1
  var loopElementName = getFunctionParam(loopElementIdx)
  var propertyValidator = visitIR(ir.elementType,)
  ## would be undefined instead of false
  var checkIfArray = fmt"()"
  var checkProperties = ""
  if isNonEmptyValidator(propertyValidator):
    checkProperties = 
  var finalCode = checkIfArray
  if checkProperties:
    finalCode += fmt"&& {wrapWithFunction(checkProperties,propertyVerifierParamIdx,state)}"
  return 

proc assertAcceptsTypeParameters(ir:IR,typeName:string):  = 
  if not isInterface(ir) and not isTypeAlias(ir):
    raise newException(MacroError,Errors.TypeDoesNotAcceptGenericParameters(typeName,ir.type))

proc replaceTypeParameters(ir:IR,replacer:proc (typeParameterIndex:float): auto ): IR = 
  ## TODO: I want to unit test this function. How?
proc helper(self:1,current:IR) = 
  for  in undefined.mitems:
    if typeof val != "object":
      discard
    if isGenericType(val):
      ## @ts-ignore
      current[key] = replacer(val.typeParameterIndex)
    elif Array.isArray(val):
      var i = 0
      while i < val.len:
        var element = val[i]
        if isGenericType(element):
          val[i] = replacer(element.typeParameterIndex)
        else:
          discard
    elif isIR(val):
      helper(val)

  var copy = deepCopy(ir)
  helper(copy)
  return copy

proc visitType(ir:Type,state:State): Validator[Ast] = 
  ## This doesn't just visit Type nodes, it also handles interfaces declarations
  ## and type alias declarations because those are the only IR nodes that can
  ## accept type parameters, and they are top level/not nested, so there is no
  ## point dispatching a visitor.

  var namedTypes = state.namedTypes

  var typeName = ir.typeName
  typeParameters = ir.typeParameters
  if isNil(typeParameters):
    typeParameters = @[]
  var referencedIr = namedTypes.get(typeName)
  if referencedIr == undefined:
    raise newException(MacroError,Errors.UnregisteredType(typeName))
  assertAcceptsTypeParameters(referencedIr,typeName)
  var key = typeName + deterministicStringify(providedTypeParameters)
  var instantiatedIr = namedTypes.get(key)
  if instantiatedIr != undefined:
    discard
  var typeParameterDefaults = referencedIr.typeParameterDefaults
  typeParametersLength = referencedIr.typeParametersLength

  if typeParametersLength < providedTypeParameters.len:
    raise newException(MacroError,Errors.TooManyTypeParameters(typeName,providedTypeParameters.len,typeParametersLength))
  var requiredTypeParameters = typeParametersLength - typeParameterDefaults.len
  if requiredTypeParameters > providedTypeParameters.len:
    raise newException(MacroError,Errors.NotEnoughTypeParameters(typeName,providedTypeParameters.len,requiredTypeParameters))
  var resolvedParameterValues:seq[IR] = providedTypeParameters
  var i = providedTypeParameters.len
  while i < typeParametersLength:
    var instantiatedDefaultValue = replaceTypeParameters(typeParameterDefaults[i],proc (typeParameterIdx:auto): auto = 
        if typeParameterIdx >= i:
          raise newException(MacroError,Errors.InvalidTypeParameterReference(i,typeParameterIdx))
        return resolvedParameterValues[typeParameterIdx]
    )
    resolvedParameterValues.add(instantiatedDefaultValue)
  var uninstantiatedType = if isTypeAlias(referencedIr): referencedIr.value else: referencedIr.body
  instantiatedIr = replaceTypeParameters(uninstantiatedType,proc (typeParameterIdx:auto): auto = 
  )
  namedTypes.set(key,instantiatedIr)
  visitIR(instantiatedIr,state)

proc getPrimitive(typeName:PrimitiveTypeName): Validator[]|Validator[] = 
  var validator = primitives.get(typeName)
  if not validator:
    throwUnexpectedError(fmt"unexpected primitive type: {typeName}")
  return validator

proc visitPrimitiveType(ir:PrimitiveType,state:State): Validator[]|Validator[] = 
  var typeName = ir.typeName

  var validator = getPrimitive(typeName)
  if isNonEmptyValidator(validator):
    return 
  return validator

proc isNonEmptyValidator(validator:Validator[Ast]):  = 
  validator.type == Ast.EXPR

proc ensureTrailingNewline(s:string): auto = 

proc visitObjectPattern(node:ObjectPattern,state:State): Validator[Ast] = 
  ## TODO: do subtype optimization
  var numberIndexerType = node.numberIndexerType
  stringIndexerType = node.stringIndexerType
  properties = node.properties

  var parentParamIdx = state.parentParamIdx

  var parentParamName = getParam(state)
  var indexSignatureFunctionParamIdx = parentParamIdx + 1
  var indexSignatureFunctionParamName = getFunctionParam(indexSignatureFunctionParamIdx)
  var destructuredKeyName = "k"
  var destructuredValueName = "v"
  var validateStringKeyCode = ""
var indexerState:State = newState(,parentParamName= destructuredValueName)  var sV = if stringIndexerType: visitIR(stringIndexerType,indexerState) else: nil
  if sV != nil and isNonEmptyValidator(sV):
    validateStringKeyCode = fmt"if (!) return false;"
  var validateNumberKeyCode = ""
  var nV = if numberIndexerType: visitIR(numberIndexerType,indexerState) else: nil
  if nV != nil and isNonEmptyValidator(nV):
    validateNumberKeyCode = fmt"if ((!isNaN() ||  === "NaN") && !) return false;"
  var indexValidatorCode = ""
  if sV or nV:
    indexValidatorCode = 
  var checkTruthy = fmt"!!{parentParamName}"
  var propertyValidatorCode = ""
  var i = 0
  while i < properties.len:
    var prop = properties[i]
    var keyName = prop.keyName
    optional = prop.optional
    value = prop.value

    ## https://stackoverflow.com/questions/54896541/validating-property-names-with-regex/54896677#54896677
    var canUseDotNotation = typeof keyName == "string" and /^(?![0-9])[a-zA-Z0-9$_]+$/.test(keyName)
    ## TODO: Check JSON.stringify won't damage the property name
    var escapedKeyName = JSON.stringify(keyName)
    var propertyAccess = if canUseDotNotation: fmt"{parentParamName}.{keyName}" else: fmt"{parentParamName}[]"
    var valueV = visitIR(value,)
    if isNonEmptyValidator(valueV):
      var code = ""
      if optional:
        ## the generated code is smaller
        code = 
      else:
        discard
      code = fmt"()"
      propertyValidatorCode += if i == 0: code else: fmt"&& {code}"
  if not indexValidatorCode and not propertyValidatorCode:
    ## no index or property signatures means it is just an empty object
    var isObjectV = getPrimitive("object")
    var isObjectCode
    if isNonEmptyValidator(isObjectV):
      isObjectCode = template(isObjectV.code,parentParamName)
    else:
      discard
    return 
  var finalCode = "("
  if indexValidatorCode:
    ## need checkTruthy so Object.entries doesn't crash
    finalCode += fmt"{checkTruthy} &&  "
  if propertyValidatorCode:
    if indexValidatorCode:
      discard
    else:
      discard
  finalCode += ")"
  return 

