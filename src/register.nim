import strformat,options

import @babel/core
import ./type-ir/typeIR
import ./macro-assertions
import ./type-ir/astToTypeIR
proc registerType(typeName:string,stmts:seq[],namedTypes:Map[string,IR]) = 
  ## TODO: Handle circular types (Well... don't handle them)
  var node = getTypeDeclarationInBlock(typeName,stmts)
  if node == nil:
    discard
  var externalTypes = Set()
  var typeIR:IR
  if t.isTSTypeAliasDeclaration(node):
    typeIR = getTypeAliasIR(node,externalTypes)
  else:
    discard
  namedTypes.set(typeName,typeIR)
  for externalType in externalTypes.mitems:
    registerType(externalType,stmts,namedTypes)

