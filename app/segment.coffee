class Segment extends Line
  intersection: (line) ->
    point = super(line)
    if Math.min(@a.x, @b.x) <= point.x <= Math.max(@a.x, @b.x) or (Math.abs(point.x - @a.x) <= 0.001 and Math.abs(point.x - @b.x) <= 0.001 and Math.min(@a.y, @b.y) <= point.y <= Math.max(@a.y, @b.y))
      point
    else
      false