import strformat,options

when not defined(js) and not defined(Nimdoc):
  {.error: "This module only works on the JavaScript platform".}


proc (object:): cstring 
