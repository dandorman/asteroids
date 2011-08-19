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
