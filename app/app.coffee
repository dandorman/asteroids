animate = do ->
  for fn in ["requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame"]
    return fn if typeof fn is "function"
  (callback) -> setTimeout(callback, 1000 / 60)

Number::sign = ->
  if this is 0
    0
  else
    if this > 0 then 1 else -1

Number::squared = -> Math.pow(this, 2)
Number::square_root = -> Math.sqrt(this)

Number::arctangent = -> Math.atan(this)
Number::cosine = -> Math.cos(this)
Number::sine = -> Math.sin(this)

class Line
  constructor: (@a, @b) ->

  intersection: (line) ->
    x: ((@a.x * @b.y - @a.y * @b.x) * (line.a.x - line.b.x) - (@a.x - @b.x) * (line.a.x * line.b.y - line.a.y * line.b.x)) / ((@a.x - @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x - line.b.x))
    y: ((@a.x * @b.y - @a.y * @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x * line.b.y - line.a.y * line.b.x)) / ((@a.x - @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x - line.b.x))

CanvasRenderingContext2D::line = (from, to, options = {}) ->
  @beginPath()
  @moveTo from.x, from.y
  @lineTo to.x, to.y
  @closePath()
  @stroke()

CanvasRenderingContext2D::circle = (at, radius, options = {}) ->
  @beginPath()
  @arc(at.x, at.y, radius, 0, 2 * Math.PI, false)
  @fill()

class Ray extends Thing
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

    ray = new Line {x: @a.x, y: @a.y}, {x: @b.x, y: @b.y}
    for segment in @b.segments()
      point = ray.intersection(segment)
      if Math.min(segment.a.x, segment.b.x) <= point.x <= Math.max(segment.a.x, segment.b.x) or (Math.abs(point.x - segment.a.x) <= 0.001 and Math.abs(point.x - segment.b.x) <= 0.001 and Math.min(segment.a.y, segment.b.y) <= point.y <= Math.max(segment.a.y, segment.b.y))
        ctx.strokeStyle = "rgba(255, 0, 0, 0.9)"
        ctx.line {x: point.x - 5, y: point.y - 5}, {x: point.x + 5, y: point.y + 5}
        ctx.line {x: point.x - 5, y: point.y + 5}, {x: point.x + 5, y: point.y - 5}

document.addEventListener 'DOMContentLoaded', (->
  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas
  ship = new Ship({x: 700, y: -100, maxSpeed: 3})
  world.addThing ship

  asteroid = new Asteroid({x: 500, y: -200})
  world.addThing asteroid

  ray = new Ray(ship, asteroid)
  world.addThing ray

  document.addEventListener 'keydown', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.fireThrusters()
      when 'A' then ship.turnLeft()
      when 'D' then ship.turnRight()
      when 'X' then ship.reset()
      when ' ' then ship.fire()
  ), false

  document.addEventListener 'keyup', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.stopThrusters()
  ), false

  animate -> world.render()
), false
