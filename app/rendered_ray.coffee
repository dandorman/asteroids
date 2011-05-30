class RenderedRay extends Thing
  constructor: (@a, @b, options = {}) ->
    options.x = 0
    options.y = 0
    super(options)

  render: (ctx) ->
    angle = ((@b.y - @a.y) / (@b.x - @a.x)).arctangent()
    angle -= Math.PI if (@b.x - @a.x < 0)
    hypotenuse = ((@b.y - @a.y).squared() + (@b.x - @a.x).squared()).square_root()

    ctx.strokeStyle = "rgba(255, 0, 0, 0.5)"
    ctx.line {x: @a.x, y: @a.y}, {x: @a.x + 1000 * hypotenuse * angle.cosine(), y: @a.y + 1000 * hypotenuse * angle.sine()}

    ray = new Ray {x: @a.x, y: @a.y}, {x: @b.x, y: @b.y}
    for segment in @b.segments()
      point = ray.intersection(segment)
      if point
        ctx.strokeStyle = "rgba(255, 0, 0, 0.9)"
        ctx.lineWidth = 3
        ctx.line {x: point.x - 5, y: point.y - 5}, {x: point.x + 5, y: point.y + 5}
        ctx.line {x: point.x - 5, y: point.y + 5}, {x: point.x + 5, y: point.y - 5}
