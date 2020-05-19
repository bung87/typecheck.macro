when not defined(js) and not defined(Nimdoc):
  {.error: "This module only works on the JavaScript platform".}


proc createValidator[T](): proc [V](value:V): auto {.importcpp.}  {.importcpp.} 
proc register(typeName:cstring): proc (): auto {.importcpp.}  {.importcpp.} 
## Functions used for testing (and maybe curious people)
var _resetAllIR:cstring
## TODO: Set the type to IR
var _dumpAllIR:
type Tag* = ref object of RootObj


var arrayTypeNames:
var primitiveTypes:
type PrimitiveTypeName* = ref object of RootObj


var indexSignatureKeyTypes:
type IndexSignatureKeyType* = ref object of RootObj


type NamedTypeDeclaration* = ref object of IR
  type*:TypeDeclarationType
  typeParameterNames*:seq[cstring]
  typeParametersLength*:float
  typeParameterDefaults*:Array[IR]


