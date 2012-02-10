express = require 'express'
app = express.createServer()

# configure server

app.register '.coffee', require 'coffeekup'
app.set 'view options', layout: false
app.set 'view engine', 'coffee'

app.configure ->
  app.use express.static "#{__dirname}/public"

port = 80
app.configure 'development', ->
  port = 3141

# routes

app.get '/', (req, res) ->
  res.render 'index.coffee'

# start server

io = require('socket.io').listen(app)
app.listen port

# socket.io

cycle = (items) ->
  [index, length] = [0, items.length]
  next: -> items[index++ % length]

ship_colors = cycle [{r: 0, g: 255, b: 0}, {r: 255, g: 0, b: 0}, {r: 0, g: 0, b: 255}]

things = {}
next_thing_id = 0

[world_width, world_height] = [1500, 1500]

io.sockets.on 'connection', (socket) ->
  new_thing = id: ++next_thing_id, x: world_width / 2, y: world_height / 2, color: ship_colors.next(), maxSpeed: 3
  things[next_thing_id] = new_thing

  tmp = {}
  tmp[next_thing_id] = new_thing
  socket.broadcast.emit 'add', tmp

  new_thing.yours = true
  socket.emit 'add', things
  socket.set 'ship_id', next_thing_id
  delete new_thing.yours

  socket.on 'ship:spawn', ->
    new_thing = id: ++next_thing_id, x: world_width / 2, y: world_height / 2, color: ship_colors.next(), maxSpeed: 3
    things[next_thing_id] = new_thing

    tmp = {}
    tmp[next_thing_id] = new_thing
    socket.broadcast.emit 'add', tmp

    new_thing.yours = true
    socket.emit 'add', things
    socket.set 'ship_id', next_thing_id
    delete new_thing.yours

  socket.on 'update', (data) ->
    thing = things[data.id]
    thing.x = data.position.x
    thing.y = data.position.y
    thing.angle = data.angle
    thing.velocity = data.velocity
    socket.broadcast.emit 'update', data

  socket.on 'ship:fired', (data) ->
    socket.broadcast.emit 'ship:fired', data

  socket.on 'ship:exploded', (data) ->
    delete things[data.id]
    socket.broadcast.emit 'delete', data.id

  socket.on 'disconnect', ->
    socket.get 'ship_id', (err, ship_id) ->
      delete things[ship_id]
      socket.broadcast.emit 'delete', ship_id
