import strformat,options

import ../../../../dist/typecheck.macro
type Foo* = ref object of RootObj


register("Foo")
createValidator()
