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

things = {}
next_thing_id = 0

[world_width, world_height] = [1500, 1500]

io.sockets.on 'connection', (socket) ->
  socket.emit 'game:joined', things

  socket.on "game:register", (data) ->
    console.log data
    socket.set "info",
      ship_id: ++next_thing_id
      name: data.n
      color: data.c
    socket.emit 'game:registered'

  socket.on 'ship:spawn', ->
    socket.get 'info', (err, info) ->
      new_thing =
        id: info.ship_id
        x: world_width / 2
        y: world_height / 2
        color: info.color
        maxSpeed: 3
      things[info.ship_id] = new_thing

      socket.broadcast.emit 'ship:spawned', new_thing

      new_thing.yours = true
      socket.emit 'ship:spawned', new_thing
      delete new_thing.yours

  socket.on 'update', (data) ->
    thing = things[data.id]
    if thing and data.p? and data.a? and data.v?
      thing.x = data.p.x
      thing.y = data.p.y
      thing.angle = data.a
      thing.velocity =
        horizontal: data.v.h
        vertical: data.v.v
      socket.broadcast.emit 'update', data
    else
      console.log "BORKED", data

  socket.on 'ship:fired', (data) ->
    socket.broadcast.emit 'ship:fired', data

  socket.on 'ship:exploded', (data) ->
    delete things[data.id]
    socket.broadcast.emit 'delete', data.id

  socket.on 'disconnect', ->
    socket.get 'ship_id', (err, ship_id) ->
      delete things[ship_id]
      socket.broadcast.emit 'delete', ship_id
