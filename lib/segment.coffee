class Segment extends Line
  intersection: (line) ->
    point = super(line)
    if point
      if (not @vertical() and Math.min(@a.x, @b.x) <= point.x <= Math.max(@a.x, @b.x)) or (not @horizontal() and Math.min(@a.y, @b.y) <= point.y <= Math.max(@a.y, @b.y)) or @has_endpoint(point)
        point

  has_endpoint: (point) ->
    (point.x - @a.x).abs() <= 0.001 and (point.y - @a.y).abs() <= 0.001 or (point.x - @b.x).abs() <= 0.001 and (point.y - @b.y).abs() <= 0.001
