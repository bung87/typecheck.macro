import strformat,options

type Tag* = ref object of RootObj


var arrayTypeNames = @["Array","ReadonlyArray"]
var primitiveTypes = @["number","bigInt","string","boolean","null","object","any","undefined","unknown"]
type PrimitiveTypeName* = ref object of RootObj


var indexSignatureKeyTypes = @["string","number"]
type IndexSignatureKeyType* = ref object of RootObj


type NamedTypeDeclaration* = ref object of IR
  type*:TypeDeclarationType
  typeParameterNames*:seq[string]  ## this is only useful for debugging

  typeParametersLength*:float
  typeParameterDefaults*:Array[IR]


