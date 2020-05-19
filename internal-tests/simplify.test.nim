import ../src/type-ir/simplifyIR
import ../src/type-ir/typeIR
test("simplify-union",proc (t:auto): auto = 
nonFlattened:Union = newUnion(type= "union",childTypes= @[,])    t.pass()
)
