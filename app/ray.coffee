class Ray extends Line
  intersection: (line) ->
    point = if line instanceof Segment
      line.intersection(this)
    else
      super(line)

    if point
      if Math.min(@a.x, @b.x, point.x) == @a.x or Math.max(@a.x, @b.x, point.x) == @a.x
        point
      else
        false
    else
      false
