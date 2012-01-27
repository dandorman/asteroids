Number::sign = ->
  if this is 0
    0
  else
    if this > 0 then 1 else -1

Number::abs = -> Math.abs(@)

Number::squared = -> Math.pow(this, 2)
Number::square_root = -> Math.sqrt(this)

Number::cosine = -> Math.cos(this)
Number::sine = -> Math.sin(this)
