animate = do ->
  for fn in ["requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame"]
    return fn if typeof fn is "function"
  (callback) -> setTimeout(callback, 1000 / 60)

Number::sign = ->
  if this is 0
    0
  else
    if this > 0 then 1 else -1

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

document.addEventListener 'DOMContentLoaded', (->
  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas
  ship = new Ship({x: 0, y: 0, maxSpeed: 3})
  world.addThing ship

  asteroid = new Asteroid({x: -200, y: -175})
  world.addThing asteroid

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
