var schema = z.object().nonstrict()
proc (o:auto): auto = 
  try:
    schema.parse(o)
    return true
  except:
    schema.parse(o)

    return true

