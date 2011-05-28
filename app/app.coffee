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

document.addEventListener 'DOMContentLoaded', (->
  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas
  ship = new Ship({x: 200, y: -200, maxSpeed: 3})
  world.addThing ship

  asteroid = new Asteroid({x: 0, y: 0, radius: 200})
  world.addThing asteroid

  ray = new RenderedRay(ship, asteroid)
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
