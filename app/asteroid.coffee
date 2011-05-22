class Asteroid extends Thing
  constructor: (options = {}) ->
    super(options)
    @radius = options.radius ? 50
    @sides = options.sides ? 5

  render: (ctx) ->
    angle = 0

    ctx.beginPath()
    [x, y] = [@radius * Math.cos(angle), @radius * Math.sin(angle)]
    ctx.moveTo(x, y)

    for side in [1...@sides]
      angle += 2 * Math.PI / @sides
      [x, y] = [@radius * Math.cos(angle), @radius * Math.sin(angle)]
      ctx.lineTo(x, y)

    ctx.closePath()
    ctx.strokeStyle = "rgb(200, 200, 200)"
    ctx.fillStyle = "rgba(200, 200, 200, 0.67)"
    ctx.stroke()
    ctx.fill()

  contains: (point) ->
    Math.sqrt(Math.pow(@x - point.x, 2) + Math.pow(@y - point.y, 2)) <= @radius
