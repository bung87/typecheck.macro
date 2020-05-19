when not defined(js) and not defined(Nimdoc):
  {.error: "This module only works on the JavaScript platform".}


proc createValidator[T](): proc [V](value:V): auto  {.importcpp.} 
proc register(typeName:cstring): proc (): auto  {.importcpp.} 
## Functions used for testing (and maybe curious people)
var _resetAllIR:cstring
## TODO: Set the type to IR
var _dumpAllIR:
type Tag* = ref object of RootObj


type IR* = ref object of RootObj
  type*:Tag

type Type* = ref object of RootObj
  type*:"type"
  typeName*:cstring
  typeParameters*:(IR,)

var arrayTypeNames:
type ArrayType* = ref object of RootObj
  type*:"arrayType"
  elementType*:IR

type GenericType* = ref object of RootObj
  type*:"genericType"
  typeParameterIndex*:float

var primitiveTypes:
type PrimitiveTypeName* = ref object of RootObj


type PrimitiveType* = ref object of RootObj
  type*:"primitiveType"
  typeName*:PrimitiveTypeName

type Literal* = ref object of RootObj
  type*:"literal"
  value*:cstring|float|bool

type Union* = ref object of RootObj
  type*:"union"
  childTypes*:(IR,IR,)

type Tuple* = ref object of RootObj
  type*:"tuple"
  firstOptionalIndex*:float ##  ## Example: [number, number?, ...string[]]
    ## ^^^^^^ = index 1 = firstOptionalIndex (fOI)
    ## childTypes.length (cLen) = 2 (amount of non-rest types)
    ## restType = ...string[]
    ## If fOI = n, the tuple must have at minimum n elements
    ## and at most cLen elements, unless there is a rest element,
    ## in which case there is no upper bound
    ## fOI <= cLen. If the tuple has no optional elements, fOI = cLen
  childTypes*:seq[IR]
  restType*:ArrayType|ArrayType

var indexSignatureKeyTypes:
type IndexSignatureKeyType* = ref object of RootObj


type ObjectPattern* = ref object of RootObj
  type*:"objectPattern"
  numberIndexerType*:IR
  stringIndexerType*:IR
  properties*:seq[PropertySignature]

type NamedTypeDeclaration* = ref object of IR
  type*:TypeDeclarationType
  typeParameterNames*:seq[cstring]
  typeParametersLength*:float
  typeParameterDefaults*:Array[IR]


type TypeAlias* = ref object of RootObj
  type*:"alias"
  value*:IR

type Interface* = ref object of RootObj
  type*:"interface"
  body*:ObjectPattern

type PropertySignature* = ref object of RootObj
  type*:"propertySignature"
  keyName*:cstring|float
  optional*:bool
  value*:IR

