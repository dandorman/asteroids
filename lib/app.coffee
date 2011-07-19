addAsteroid = do ->
  pending = false
  (world, ship) ->
    unless pending
      pending = true

      setTimeout () ->
        radius = Math.floor(Math.random() * 50) + 100

        [x, y] = [
          Math.floor(Math.random() * world.canvas.width) - world.quadrant.width,
          Math.floor(Math.random() * world.canvas.height) - world.quadrant.height
        ] while distance_between_points({x: x ? ship.x, y: y ? ship.y}, ship.position()) < 50 + radius

        asteroid = new Asteroid
          x: x
          y: y
          radius: radius
          sides: Math.floor(Math.random() * 5) + 5
          rateOfRotation: Math.floor(Math.random() * 60) + 80
          velocity:
            horizontal: Math.random() * 4 - 2
            vertical: Math.random() * 4 - 2
        world.addThing asteroid
        pending = false
      , (Math.floor(Math.random() * 3) + 1) * 1000

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
      addAsteroid(world, ship)
      oldRender.call world

  document.addEventListener 'keydown', ((event) ->
    charCode = String.fromCharCode event.which
    if charCode in ['W', 'A', 'D', ' ']
      event.preventDefault()
      switch String.fromCharCode event.which
        when 'W' then ship.fireThrusters()
        when 'A' then ship.turnLeft()
        when 'D' then ship.turnRight()
        when ' ' then ship.fire()
  ), false

  document.addEventListener 'keyup', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.stopThrusters()
  ), false

  animate -> world.render()
), false
