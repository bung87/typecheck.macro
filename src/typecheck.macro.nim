import strformat,options

import @babel/core
import ./macro-assertions
import ./type-ir/typeIR
import ./register
import ./type-ir/astToTypeIR
import ./code-gen/irToInline
proc macroHandler(:MacroParams) = 
  var namedTypes:Map[string,IR] = Map()
  if references.register:
    for path in undefined.mitems:
      var callExpr = path.parentPath
      var typeName = getRegisterArguments(path)
      var stmtsInSameScope = getStatementsInSameScope(path)
      registerType(typeName,stmtsInSameScope,namedTypes)
      callExpr.remove()
  if references.default:
    for path in undefined.mitems:
      var callExpr = path.parentPath
      var typeParam = getTypeParameter(path)
      var ir = getTypeParameterIR(typeParam.node)
      var code = generateValidator(ir,namedTypes)
      var parsed = parse(code)
      if t.isFile(parsed):
        callExpr.replaceWith(parsed.program.body[0])
      else:
        discard
  if references._dumpAllIR:
    references._dumpAllIR.forEach(proc (path:auto): auto = 
      ## convert the map to a json-serializable object
      var obj:Record[string,IR] = Object.create(nil)
      for  in undefined.mitems:
        obj[key] = val
      var stringifiedIr = JSON.stringify(obj)
      ## makes it an expression
      var irAsAst = parse(fmt"()")
      if t.isFile(irAsAst):
        path.replaceWith(irAsAst.program.body[0])
      else:
        discard
    )

