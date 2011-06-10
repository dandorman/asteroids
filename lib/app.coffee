document.addEventListener 'DOMContentLoaded', (->
  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas
  ship = new Ship({x: 200, y: -200, maxSpeed: 3})
  world.addThing ship

  asteroid = new Asteroid({x: 0, y: 0, radius: 200})
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
