import strformat,options

import ../../../dist/typecheck.macro
import ./__helpers__
proc (t:ExecutionContext): auto = 
type Personality* = ref object of RootObj
  isNice*:bool
  numFriends*:float


type PetOwner* = ref object of RootObj
  name*:string
  personality*:Personality
  pet*:Pet


  register("Dog")
  register("PetOwner")
  var isDogOwner = createValidator()
var owner = new(name= "anthony",pet= ,personality= )var notOwner = new(,pet= nil)  tBV(t,isDogOwner,)
  tBV(t,isDogOwner,)
