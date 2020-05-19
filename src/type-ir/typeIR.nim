import strformat,options

type Tag* = ref object of RootObj


type IR* = ref object of RootObj
  type*:Tag

type Type* = ref object of RootObj
  type*:"type"
  typeName*:string
  typeParameters*:(IR,)

var arrayTypeNames = @["Array","ReadonlyArray"]
type ArrayType* = ref object of RootObj
  type*:"arrayType"
  elementType*:IR

type GenericType* = ref object of RootObj
  type*:"genericType"
  typeParameterIndex*:float

var primitiveTypes = @["number","bigInt","string","boolean","null","object","any","undefined","unknown"]
type PrimitiveTypeName* = ref object of RootObj


type PrimitiveType* = ref object of RootObj
  type*:"primitiveType"
  typeName*:PrimitiveTypeName

type Literal* = ref object of RootObj
  type*:"literal"
  value*:string|float|bool

type Union* = ref object of RootObj
  type*:"union"
  childTypes*:(IR,IR,)

type Intersection* = ref object of RootObj
  type*:"intersection"
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

var indexSignatureKeyTypes = @["string","number"]
type IndexSignatureKeyType* = ref object of RootObj


type ObjectPattern* = ref object of RootObj
  type*:"objectPattern"
  numberIndexerType*:IR
  stringIndexerType*:IR
  properties*:seq[PropertySignature]

type NamedTypeDeclaration* = ref object of IR
  type*:TypeDeclarationType
  typeParameterNames*:seq[string]  ## this is only useful for debugging

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
  keyName*:string|float ##  ## keyName encodes both name and value (string or number)
  optional*:bool
  value*:IR

