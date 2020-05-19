import strformat,options

proc hasAtLeast1Element[T](array:seq[T]):  = 
  array.len >= 1

proc hasAtLeast2Elements[T](array:seq[T]):  = 
  array.len >= 2

