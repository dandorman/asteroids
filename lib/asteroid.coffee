class Asteroid extends Thing
  constructor: (options = {}) ->
    super(options)
    @radius = options.radius ? 50
    @sides = options.sides ? 5
    @angle = 0

    @strokeStyle = "rgb(200, 200, 200)"
    @fillStyle = "rgba(200, 200, 200, 0.67)"

  update: ->
    super()
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
    ctx.strokeStyle = @strokeStyle
    ctx.fillStyle = @fillStyle
    ctx.stroke()
    ctx.fill()

  contains: (point) ->
    current_position = @position()
    return false if distance_between_points(point, current_position) > @radius

    ray = new Ray point, current_position
    intersections = []
    for segment in @segments()
      point = ray.intersection(segment)
      if point
        unique = true
        for intersection in intersections
          if Math.abs(point.x - intersection.x) < 0.001 and Math.abs(point.y - intersection.y) < 0.001
            unique = false
            break
        intersections.push point if unique
    intersections.length > 0 and intersections.length % 2

  segments: ->
    for index in [0...@points.length]
      new Segment @points[index], @points[(index + 1) % @points.length]

  collided_with: (thing) ->
    if thing instanceof Bullet
      @radius -= 10
      @cull = true if @radius <= 50
