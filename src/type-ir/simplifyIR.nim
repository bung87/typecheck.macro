import strformat,options

import ./typeIR
import ../macro-assertions
import ../utils/checks
proc traverse[T](ir:Readonly[IR],shouldProcess:proc (obj:): auto ,process:proc (obj:T): auto ): IR = 
proc helper(self:1,current:IR): auto = 
  for  in undefined.mitems:
    if typeof v != "object" or v == nil:
      discard
    if shouldProcess(v):
      ## @ts-ignore
      current[k] = process(v)
    elif Array.isArray(v):
      var i = 0
      while i < v.len:
        var element = v[i]
        if shouldProcess(element):
          v[i] = process(element)
        else:
          discard
    else:
      discard

  var copy = deepCopy(ir)
  helper(copy)
  return copy

proc isUnion(x:IR):  = 

proc isIntersection(x:IR):  = 

proc isIntersectionOrUnion(x:IR):  = 

type State* = ref object of RootObj
  idx*:float
  level*:float
  map*:Map[float,IR]
  mustBeTrue*:Set[float]


proc simplify(ir:Intersection|Union): Union|Intersection = 
  ## TODO: Implement lookup table to improve perf
  var map = Map()
state = new(idx= 0,map= map,level= - 1,mustBeTrue= Set())  var expression = visit(ir,state)
  var minBitsRequired = Infinity
bitConfigs:Array[Array[float]] = newArray[Array[float]]()  var i = 0
  while i < Math.pow(2,state.idx):
    var copy = expression.slice()
    var bitsSet = 0
    trueBitIdxs = new()    var j = 0
    while j < i:
      var jthBitIsSet = i and 1 shl j
      if jthBitIsSet:
        discard
      trueBitIdxs.add(j)
      if state.mustBeTrue.has(j) and not jthBitIsSet:
        discard
      copy.replace(fmt"{j}{}",if jthBitIsSet: "true" else: "false")
    if bitsSet > minBitsRequired:
      discard
    var res:bool = eval(copy)
    if res and bitsSet < minBitsRequired:
      bitConfigs = @[]
    bitConfigs.add(trueBitIdxs)
  if bitConfigs.len == 0:
    throwMaybeAstError(fmt"for type: , could not find valid type")
irConfigs:seq[IR] = newSeq[IR]()  for config in bitConfigs.mitems:
childTypes:seq[IR] = newSeq[IR]()    for idx in config.mitems:
      var ir = map.get(idx)
      if ir == undefined:
        throwUnexpectedError(fmt"could not de-serialize idx  back into type")
      childTypes.add(ir)
    if childTypes.len == 1:
      irConfigs.add(childTypes[0])
    elif hasAtLeast2Elements(childTypes):
      intersection:Intersection = newIntersection(type= "intersection",childTypes= childTypes)      irConfigs.add(intersection)
    else:
      discard
  if irConfigs.len == 1:
    var intersection = irConfigs[0]
    if isIntersection(intersection):
      return intersection
    else:
      discard
  elif hasAtLeast2Elements(irConfigs):
    union:Union = newUnion(type= "union",childTypes= irConfigs)    return union
  else:
    discard

proc visit(ir:Intersection|Union,state:State): string = 
  state.level += 1
  var irIsUnion = isUnion(ir)
  var childTypes = ir.childTypes

  var expr = "("
  var i = 0
  while i < childTypes.len:
    var type = childTypes[i]
    var childExpr = ""
    if isUnion(type) or isIntersection(type):
      childExpr = visit(type,state)
    else:
      discard
    expr += if i == 0: childExpr else: fmt"{if irIsUnion: "&&" else: "||"} {childExpr}"
  expr & ")"

proc simplifyUnionsAndIntersections(ir:IR): auto = 
  traverse(ir,isIntersectionOrUnion,proc (cur:auto): auto = 
        simplify(cur)
  )

