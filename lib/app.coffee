addAsteroid = do ->
  pending = false
  (world) ->
    unless pending
      pending = true
      setTimeout () ->
        asteroid = new Asteroid
          x: Math.floor(Math.random() * world.canvas.width)  - world.quadrant.width
          y: Math.floor(Math.random() * world.canvas.height) - world.quadrant.height
          radius: Math.floor(Math.random() * 50) + 100
          sides: Math.floor(Math.random() * 5) + 5
          velocity:
            horizontal: Math.random() * 2 - 1
            vertical: Math.random() * 2 - 1
        world.addThing asteroid
        pending = false
      , 3000

document.addEventListener 'DOMContentLoaded', (->
  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas

  ship = new Ship x: 0, y: 0, maxSpeed: 3
  world.addThing ship

  world.render = do () ->
    oldRender = world.render
    () ->
      addAsteroid(world)
      oldRender.call world

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
