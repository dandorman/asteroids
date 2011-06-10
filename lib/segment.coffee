class Segment extends Line
  intersection: (line) ->
    point = super(line)
    if point
      if (!@vertical() and Math.min(@a.x, @b.x) <= point.x <= Math.max(@a.x, @b.x)) or (!@horizontal() and Math.min(@a.y, @b.y) <= point.y <= Math.max(@a.y, @b.y)) or @has_endpoint(point)
        point

  has_endpoint: (point) ->
    Math.abs(point.x - @a.x) <= 0.001 and Math.abs(point.y - @a.y) <= 0.001 or Math.abs(point.x - @b.x) <= 0.001 and Math.abs(point.y - @b.y) <= 0.001
