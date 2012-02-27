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

create_walls = (world) ->
  world.addThing new Wall(x: 10, y: 10, end: { x: world.width - 10, y: 10 }, kill: "top")
  world.addThing new Wall(x: 10, y: world.height - 10, end: { x: world.width - 10, y: world.height - 10 }, kill: "bottom")
  world.addThing new Wall(x: 10, y: 10, end: { x: 10, y: world.height - 10 }, kill: "left")
  world.addThing new Wall(x: world.width - 10, y: 10, end: { x: world.width - 10, y: world.height - 10 }, kill: "right")

$.domReady ->
  canvas = $("canvas")[0]

  world = new World canvas
  create_walls(world)

  ship = null
  shipObserver = new ShipObserver(socket)

  socket.on 'game:joined', (things) ->
    for id, data of things
      thing = new Ship(data)
      world.addThing thing

  socket.on 'ship:spawned', (data) ->
    thing = new Ship(data)
    world.addThing thing

    if data.yours
      ship = thing
      ship.update = ((original_update) ->
        ->
          original_update.call(@)
          world.center_viewport_at(@x, @y)
      )(ship.update)

      $(".connection-status").hide()

  socket.on 'update', (data) ->
    thing = world.getThing data.id
    thing.x = data.p.x
    thing.y = data.p.y
    thing.angle = data.a
    thing.velocity =
      horizontal: data.v.h
      vertical: data.v.v

  socket.on 'ship:fired', (data) ->
    world.addThing new Bullet
      x: data.p.x
      y: data.p.y
      velocity:
        horizontal: data.v.h
        vertical: data.v.v
      lifespan: 1000

  socket.on 'delete', (id) ->
    thing = world.getThing id
    thing and thing.explode?()

  socket.on 'disconnect', (id) ->
    world.things = []
    create_walls(world)
    ship = null
    $(".connection-status").show()

  document.addEventListener 'keydown', ((event) ->
    charCode = String.fromCharCode event.which
    if ship and not ship.cull?
      if charCode in ['W', 'A', 'D', ' ']
        event.preventDefault()
        switch String.fromCharCode event.which
          when 'W' then ship.fireThrusters()
          when 'A' then ship.turnLeft()
          when 'D' then ship.turnRight()
          when ' ' then ship.fire()
    else
      if charCode is ' '
        socket.emit 'ship:spawn'
  ), false

  # maybe set this up so it only fires if the players hasn't pressed anything in
  # a while?
  setInterval (->
    return unless ship and not ship.cull
    publish 'ship:moved', [ship]
  ), 1000

  document.addEventListener 'keyup', ((event) ->
    return unless ship

    switch String.fromCharCode event.which
      when 'W' then ship.stopThrusters()
  ), false

  $('form').submit (e) ->
    e.stopPropagation()
    e.preventDefault()

    name = $('form [name=name]').val()
    red = parseInt $('form [name=red]').val()
    green = parseInt $('form [name=green]').val()
    blue = parseInt $("form [name=blue]").val()
    socket.emit "game:register", n: name, c: r: red, g: green, b: blue

  animate -> world.render()