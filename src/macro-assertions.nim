import strformat,options

import @babel/core
import ./type-ir/typeIR
ErrorBase = new(ValidatorNoTypeParameter= "Failed to find type parameter. createValidator should be called with a type parameter. Example: "createValidator<TypeName>()"",NotCalledAsFunction= "Macro should be called as function but was called as a",MoreThanOneTypeParameter= "Macro should be called with 1 type parameter but was called with",RegisterInvalidCall= ,UnregisteredType= "Tried to generate a validator for an unregistered type with name",RegisterInvalidNumberParams= "register should be called with 1 argument, but it was called with",RegisterParam1NotStringLiteral= "register's first (and only) parameter should be a string literal, which is the name of the type to register, but it was a",TypeDoesNotAcceptGenericParameters= "types don't accept generic parameters",TooManyTypeParameters= "even though it only accepts",NotEnoughTypeParameters= "type parameters even though it requires at least",InvalidTypeParameterReference= "tried to reference the default type parameter in position:")proc removePeriod(str:string): auto = 

proc addNewline(str:string): auto = 

Errors = new(NoTypeParameters= proc (): auto = 
,NotCalledAsFunction= proc (callType:string): auto = 
,MoreThanOneTypeParameter= proc (typeParams:float): auto = 
,InvalidRegisterCall= proc (): auto = 
,InvalidNumberOfRegisterParams= proc (params:float): auto = 
,RegisterParam1NotStringLiteral= proc (paramNode:): auto = 
,UnregisteredType= proc (typeName:string): auto = 
,TypeDoesNotAcceptGenericParameters= proc (typeName:string,nodeType:Tag): auto = 
,TooManyTypeParameters= proc (typeName:string,provided:float,actual:float): auto = 
,NotEnoughTypeParameters= proc (typeName:string,provided:float,actual:float): auto = 
,InvalidTypeParameterReference= proc (paramPosition:float,referencedPosition:float): auto = 
,UnexpectedError= proc (reason:string): auto = 
  return 
,MaybeAstError= proc (reason:string,optional:string|nil): auto = 
  return 
)proc throwUnexpectedError*(msg:auto): auto = 
  raise newException(MacroError,Errors.UnexpectedError(msg))

proc throwMaybeAstError*(msg:auto,optional:auto): auto = 
  raise newException(MacroError,Errors.MaybeAstError(msg,optional))

proc assertCallExpr(expr:NodePath[]):  = 
  if not expr.isCallExpression():
    discard

proc assertSingular[T](expr:seq[NodePath[T]]|NodePath[T]):  = 
  if expr == nil or expr == undefined or Array.isArray(expr):
    raise newException(MacroError,Errors.UnexpectedError(fmt"expected expr to be single NodePath but it was {expr}"))

proc getTypeDeclarationInBlock(typeName:string,stmts:seq[],idxInBlock = none(float)): || = 
  var i = 0
  while i < stmts.len:
    if i == idxInBlock:
      discard
    var stmt = stmts[i]
    if t.isTSInterfaceDeclaration(stmt) or t.isTSTypeAliasDeclaration(stmt):
      var declarationName = stmt.id.name
      if declarationName == typeName:
        return stmt
  return nil

proc getRegisterArguments(macroPath:NodePath[]): string = 
  ## dumpIr will use this too
  var callExpr = macroPath.parentPath
  assertCallExpr(callExpr)
  var args = callExpr.node.arguments
  if args.len != 1:
    raise newException(MacroError,Errors.InvalidNumberOfRegisterParams(args.len))
  var typeNamePath = callExpr.get("arguments.0")
  assertSingular(typeNamePath)
  if not typeNamePath.isStringLiteral():
    raise newException(MacroError,Errors.RegisterParam1NotStringLiteral(typeNamePath.node))
  var confident = typeNamePath.evaluate().confident
  value = typeNamePath.evaluate().value

  if confident == false or typeof typeName != "string":
    throwUnexpectedError(fmt"evaluation result had type  and confidence {typeof typeName}")
  return typeName

proc getBlockParent(macroPath:NodePath[]): seq[] = 
  var callExpr = macroPath.parentPath
  assertCallExpr(callExpr)
  var exprStmt = callExpr.parentPath
  if not exprStmt.isExpressionStatement():
    discard
  var node = exprStmt.parentPath.node

  if not t.isProgram(node) and not t.isBlock(node):
    raise newException(MacroError,Errors.InvalidRegisterCall())
  else:
    discard

proc getTypeParameter(macroPath:NodePath[]): NodePath[] = 
  var callExpr = macroPath.parentPath
  assertCallExpr(callExpr)
  var typeParametersPath = callExpr.get("typeParameters")
  if typeParametersPath and not Array.isArray(typeParametersPath) and typeParametersPath.node:
    var node = typeParametersPath.node

    if t.isTSTypeParameterInstantiation(node):
      var params = node.params.len
      if params != 1:
        discard
      var typeParameterPath = typeParametersPath.get("params.0")
      if not Array.isArray(typeParameterPath) and typeParameterPath.isTSType():
        return typeParameterPath
      throwUnexpectedError(fmt"typeParameter was {if Array.isArray(typeParameterPath): "an array" else: "not a TSType"}")
    throwUnexpectedError(fmt"typeParameters node was  instead of TSTypeParameterInstantiation")
  else:
    discard

