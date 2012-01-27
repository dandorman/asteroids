#addAsteroid = do ->
  #pending = false
  #(world, ship) ->
    #unless pending
      #pending = true

      #setTimeout () ->
        #radius = Math.floor(Math.random() * 50) + 100

        #[x, y] = [
          #Math.floor(Math.random() * world.canvas.width) - world.quadrant.width,
          #Math.floor(Math.random() * world.canvas.height) - world.quadrant.height
        #] while distance_between_points({x: x ? ship.x, y: y ? ship.y}, ship.position()) < 50 + radius

        #asteroid = new Asteroid
          #x: x
          #y: y
          #radius: radius
          #sides: Math.floor(Math.random() * 5) + 5
          #rateOfRotation: Math.floor(Math.random() * 60) + 80
          #velocity:
            #horizontal: Math.random() * 4 - 2
            #vertical: Math.random() * 4 - 2
        #world.addThing asteroid
        #pending = false
      #, (Math.floor(Math.random() * 3) + 1) * 1000

socket = io.connect "/"

document.addEventListener 'DOMContentLoaded', (->
  canvas = document.getElementsByTagName('canvas')[0]

  world = new World canvas
  ship = null

  shipObserver = new ShipObserver(socket)

  socket.on 'add', (things) ->
    for id, data of things
      thing = new Ship(data)
      world.addThing thing
      if data.yours
        ship = thing
        ship.update = ((original_update) ->
          ->
            original_update.call(@)
            world.center_viewport_at(@x, @y)
        )(ship.update)

  socket.on 'update', (data) ->
    thing = world.getThing data.id
    thing.x = data.position.x
    thing.y = data.position.y
    thing.angle = data.angle
    thing.velocity = data.velocity

  socket.on 'ship:fired', (data) ->
    world.addThing new Bullet
      x: data.position.x,
      y: data.position.y,
      velocity: data.velocity,
      lifespan: 10000

  socket.on 'delete', (id) ->
    thing = world.getThing id
    thing.explode?()

  document.addEventListener 'keydown', ((event) ->
    return if ship.cull

    charCode = String.fromCharCode event.which
    if charCode in ['W', 'A', 'D', ' ']
      event.preventDefault()
      switch String.fromCharCode event.which
        when 'W' then ship.fireThrusters()
        when 'A' then ship.turnLeft()
        when 'D' then ship.turnRight()
        when ' ' then ship.fire()
  ), false

  setInterval (->
    return if ship.cull
    publish 'ship:moved', [ship]
  ), 1000

  document.addEventListener 'keyup', ((event) ->
    return unless ship

    switch String.fromCharCode event.which
      when 'W' then ship.stopThrusters()
  ), false

  animate -> world.render()
), false
