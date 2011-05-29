class Ray extends Line
  intersection: (line) ->
    point = if line instanceof Segment
      line.intersection(this)
    else
      super(line)

    point if point and (Math.min(@a.x, @b.x, point.x) is @a.x or Math.max(@a.x, @b.x, point.x) is @a.x)
