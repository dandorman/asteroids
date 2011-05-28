class Asteroid extends Thing
  constructor: (options = {}) ->
    super(options)
    @radius = options.radius ? 50
    @sides = options.sides ? 5
    @points = []
    @angle = 0

  update: ->
    @angle += Math.PI / 120

  render: (ctx) ->
    angle = @angle

    ctx.beginPath()
    [x, y] = [@radius * Math.cos(angle), @radius * Math.sin(angle)]
    @points = [{x: @x + x, y: @y + y}]
    ctx.moveTo(x, y)

    for side in [1...@sides]
      angle += 2 * Math.PI / @sides
      [x, y] = [@radius * Math.cos(angle), @radius * Math.sin(angle)]
      @points.push {x: @x + x, y: @y + y}
      ctx.lineTo(x, y)

    ctx.closePath()
    ctx.strokeStyle = "rgb(200, 200, 200)"
    ctx.fillStyle = "rgba(200, 200, 200, 0.67)"
    ctx.stroke()
    ctx.fill()

  contains: (point) ->
    Math.sqrt(Math.pow(@x - point.x, 2) + Math.pow(@y - point.y, 2)) <= @radius

  segments: ->
    for index in [0...@points.length]
      new Segment @points[index], @points[(index + 1) % @points.length]
