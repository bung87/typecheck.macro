import strformat,options

import @babel/core
import ./typeIR
import ../utils/checks
import ../macro-assertions
proc assertArrayType(node:IR):  = 
  if node.type != "arrayType":
    throwUnexpectedError(fmt"node had type:  instead of arrayType")

proc assertTypeAnnotation(node:undefined):  = 
  if node == nil:
    throwMaybeAstError("type annotation was null")

proc assertPrimitiveType(type:string):  = 
  ## https://github.com/microsoft/TypeScript/issues/38447
  if not primitiveTypes.includes(type):
    throwUnexpectedError(fmt"{type} is not a builtin type")

type IrGenState* = ref object of RootObj
  externalTypes*:Set[string]
  typeParameterNames*:ReadonlyArray[string]
  parent*:|||

proc getInterfaceIR(node:,externalTypes:Set[string]): Interface = 
  ## 2. they can have type parameters
  var typeParameterInfo = processGenericTypeParameters(node.typeParameters,externalTypes)
var interface_:Interface = newInterface(type= "interface",,body= getBodyIR(node.body.body,))  return interface_

proc getTypeAliasIR(node:,externalTypes:Set[string]): TypeAlias = 
  ## but separation is good in case we implement "extends" in the future
  var typeParameterInfo = processGenericTypeParameters(node.typeParameters,externalTypes)
var alias:TypeAlias = newTypeAlias(type= "alias",,value= getIR(node.typeAnnotation,))  return alias

proc processGenericTypeParameters(node:||nil,externalTypes:Set[string]): auto = 
  var typeParameterNames:seq[string] = @[]
  var typeParameterDefaults:seq[IR] = @[]
var typeParameterInfo = new(typeParameterNames= typeParameterNames,typeParameterDefaults= typeParameterDefaults)  if node == undefined or node == nil:
    return 
  for param in undefined.mitems:
    if param.default:
      typeParameterDefaults.add(getIR(param.default,))
    typeParameterNames.add(param.name)
  return 

proc getBodyIR(elements:seq[],state:IrGenState): ObjectPattern = 
  ## parse the body of a Typescript interface or object pattern
var indexSignatures:PartialRecord[IndexSignatureKeyType,IR] = newPartialRecord[IndexSignatureKeyType,IR]()
  var propertySignatures:seq[PropertySignature] = @[]
  for element in elements.mitems:
    if t.isTSIndexSignature(element):
      var keyTypeAnnotation = 
      if t.isTSTypeAnnotation(keyTypeAnnotation):
        var indexType = keyTypeAnnotation.typeAnnotation.type
        var keyType:IndexSignatureKeyType
        case indexType:
          of "TSNumberKeyword":
            keyType = "number"
          of "TSStringKeyword":
            keyType = "string"
          else:
            throwMaybeAstError(fmt"indexType had an unexpected value: {indexType}")
        assertTypeAnnotation(element.typeAnnotation)
        indexSignatures[keyType] = getIR(element.typeAnnotation.typeAnnotation,state)
      else:
        discard
    elif t.isTSPropertySignature(element):
      var key = element.key

      if t.isIdentifier(key) or t.isStringLiteral(key) or t.isNumericLiteral(key):
        var keyName = if t.isIdentifier(key): key.name else: key.value
        if typeof keyName == "string" or typeof keyName == "number":
          var optional = Boolean(element.optional)
          assertTypeAnnotation(element.typeAnnotation)
          propertySignatures.add()
        else:
          discard
      else:
        discard
    elif t.isTSMethodSignature(element):
      raise newException(MacroError,"Method signatures in interfaces and type literals are not supported")
    else:
      discard
var  = new(indexSignatures.number,indexSignatures.string)var objectPattern:ObjectPattern = newObjectPattern(type= "objectPattern",properties= propertySignatures,,)  return objectPattern

proc getTypeParameterIR(node:): IR = 
  getIR(node,)

proc getIR(node:,oldState:IrGenState): IR = 
var state = new(,parent= node)  if t.isTSUnionType(node):
    var children:seq[IR] = @[]
    for childType in undefined.mitems:
      children.add(getIR(childType,state))
    if hasAtLeast2Elements(children):
      var union:Union = newUnion(type= "union",childTypes= children)  return union
    else:
      discard
  elif t.isTSParenthesizedType(node):
    ## Parenthesis are redundant in most cases. Examples:
    ## (A | B)[] = Array<A | B>
    ## (A) = A
    ## (A | B) | (C & D) = A | B | C & D
    ## - typescript does parenthesization automatically
    ## The only non-redundant case is:
    ## A & (B | C) = A & B | A & C
    ## In other words, the parent must be an intersection type
    ## and the child must be an union type.
    ## We just strip parenthesis here.
    ## We handle expanding A & (B | C) later

    var childType = node.typeAnnotation
    getIR(childType,state)
  elif t.isTSIntersectionType(node):
    var childTypes:seq[IR] = @[]
    for childType in undefined.mitems:
      childTypes.add(getIR(childType,state))
    if hasAtLeast2Elements(childTypes):
      var intersectionType:Intersection = newIntersection(type= "intersection",childTypes= childTypes)  return intersectionType
    else:
      discard
  elif t.isTSTupleType(node):
    var firstOptionalIndex = - 1
    var restType:ArrayType = nil
    var children:seq[IR] = @[]
    var elementTypes = node.elementTypes

    var len = elementTypes.len
    var i = 0
    while i < len:
      var child = elementTypes[i]
      if t.isTSOptionalType(child):
        if firstOptionalIndex == - 1:
          discard
        children.add(getIR(child.typeAnnotation,state))
      elif t.isTSRestType(child):
        if i != len - 1:
          throwMaybeAstError(fmt"rest element was not last type in tuple type because it had index {i}")
        var ir = getIR(child.typeAnnotation,state)
        assertArrayType(ir)
        restType = ir
      else:
        discard
    if firstOptionalIndex == - 1:
      firstOptionalIndex = if restType: len - 1 else: len
    if firstOptionalIndex == - 1:
      discard
    var tuple:Tuple = newTuple(type= "tuple",childTypes= children,firstOptionalIndex= firstOptionalIndex,)    return tuple
  elif t.isTSArrayType(node):
    var arrayLiteralType:ArrayType = newArrayType(type= "arrayType",elementType= getIR(node.elementType,state))    return arrayLiteralType
  elif t.isTSTypeLiteral(node):
    getBodyIR(node.members,state)
  elif t.isTSTypeReference(node):
    var typeParameters:seq[IR] = @[]
    if node.typeParameters:
      for param in undefined.mitems:
        typeParameters.add(getIR(param,state))
    if t.isTSQualifiedName(node.typeName):
      ## TODO: When does a TSQualifiedName pop-up?
      throwUnexpectedError("typeName was a TSQualifiedName instead of Identifier.")
    var typeParameterNames = state.typeParameterNames
    externalTypes = state.externalTypes

    var typeName = node.typeName.name
    var idx = typeParameterNames.indexOf(typeName)
    if idx != - 1:
      if typeParameters.len > 0:
        throwMaybeAstError(fmt"Generic parameter  had type arguments")
      var genericType:GenericType = newGenericType(type= "genericType",typeParameterIndex= idx)  return genericType
    if arrayTypeNames.includes(typeName):
      if typeParameters.len != 1:
        throwMaybeAstError(fmt"type  has 1 generic parameter but found {typeName}")
      var array:ArrayType = newArrayType(type= "arrayType",elementType= typeParameters[0])  return array
    ## a generic parameter to the parent interface
    externalTypes.add(typeName)
    var withoutTypeParameters:Type = newType(type= "type",typeName= node.typeName.name)    if hasAtLeast1Element(typeParameters):
      var type:Type = newType(,typeParameters= typeParameters)  return type
    return withoutTypeParameters
  elif t.isTSLiteralType(node):
    var value = node.literal.value
    var literal:Literal = newLiteral(type= "literal",value= value)    return literal
  elif t.isTSNumberKeyword(node) or t.isTSBigIntKeyword(node) or t.isTSStringKeyword(node) or t.isTSBooleanKeyword(node) or t.isTSObjectKeyword(node) or t.isTSNullKeyword(node) or t.isTSUndefinedKeyword(node) or t.isTSAnyKeyword(node) or t.isTSUnknownKeyword(node):
    var type = node.type

    ## type is "TSNumberKeyword", "TSStringKeyword", etc.
    var builtinTypeName = type.slice("TS".len,- "Keyword".len).toLowerCase()
    assertPrimitiveType(builtinTypeName)
    var builtinType:PrimitiveType = newPrimitiveType(type= "primitiveType",typeName= builtinTypeName)    return builtinType
  elif t.isTSIntersectionType(node) or t.isTSMappedType(node):
    raise newException(MacroError,fmt"{node.type} types are not supported. File an issue with the developer if you want this.")
  else:
    discard

