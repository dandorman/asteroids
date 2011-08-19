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
  port = 3000

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

io.sockets.on 'connection', (socket) ->
  new_thing = id: ++next_thing_id, x: 0, y: 0, color: ship_colors.next(), maxSpeed: 3
  things[next_thing_id] = new_thing

  tmp = {}
  tmp[next_thing_id] = new_thing
  socket.broadcast.emit 'add', tmp

  new_thing.yours = true
  socket.emit 'add', things
  delete new_thing.yours

  socket.on 'update', (data) ->
    thing = things[data.id]
    thing.x = data.position.x
    thing.y = data.position.y
    thing.angle = data.angle
    thing.velocity = data.velocity
    socket.broadcast.emit 'update', data
