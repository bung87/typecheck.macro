## createValidator is a compile time macro. Even though it looks like/
## is called like a function, it isn't a function. At compile time,
## all instances of createValidator are replaced with actual validator
## functions.

var isFruit = createValidator()
console.log(isFruit())
## true
console.log(isFruit())
console.log(isFruit())
## register is another compile time macro. If you want to use a named type
## as a type parameter to createValidator, you must register it.
## All usages of register are evaluated before any usage of createValidator.
## (This works b/c compile time macros are evaluated by the... compiler,
## and not the JS runtime).
## register can be called anywhere in the same scope as the type it is
## registering.

register("Cat")
var isCat = createValidator()
console.log(isCat())
console.log(isCat())
var isCatOwner = createValidator()
cordelia:Cat = newCat(name= "cordelia",breed= "sphynx")console.log(isCatOwner())
## true
console.log(isCatOwner())
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
owner = new(name= "anthony",pet= ,personality= )console.log(isDogOwner(owner))
## true
owner.pet.wagsTail = nil
console.log(isDogOwner(owner))
## let's go crazy!
var isComplexType = createValidator()
console.log(isComplexType())
