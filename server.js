(function() {
  var app, express, io, next_thing_id, port, things, world_height, world_width, _ref;

  express = require('express');

  app = express.createServer();

  app.register('.coffee', require('coffeekup'));

  app.set('view options', {
    layout: false
  });

  app.set('view engine', 'coffee');

  app.configure(function() {
    return app.use(express.static("" + __dirname + "/public"));
  });

  port = 80;

  app.configure('development', function() {
    return port = 3141;
  });

  app.get('/', function(req, res) {
    return res.render('index.coffee');
  });

  io = require('socket.io').listen(app);

  app.listen(port);

  things = {};

  next_thing_id = 0;

  _ref = [1500, 1500], world_width = _ref[0], world_height = _ref[1];

  io.sockets.on('connection', function(socket) {
    socket.emit('game:joined', things);
    socket.on("game:register", function(data) {
      console.log(data);
      socket.set("info", {
        ship_id: ++next_thing_id,
        name: data.n,
        color: data.c
      });
      return socket.emit('game:registered');
    });
    socket.on('ship:spawn', function() {
      return socket.get('info', function(err, info) {
        var new_thing;
        new_thing = {
          id: info.ship_id,
          x: world_width / 2,
          y: world_height / 2,
          color: info.color,
          maxSpeed: 3
        };
        things[info.ship_id] = new_thing;
        socket.broadcast.emit('ship:spawned', new_thing);
        new_thing.yours = true;
        socket.emit('ship:spawned', new_thing);
        return delete new_thing.yours;
      });
    });
    socket.on('update', function(data) {
      var thing;
      thing = things[data.id];
      if (thing && (data.p != null) && (data.a != null) && (data.v != null)) {
        thing.x = data.p.x;
        thing.y = data.p.y;
        thing.angle = data.a;
        thing.velocity = {
          horizontal: data.v.h,
          vertical: data.v.v
        };
        return socket.broadcast.emit('update', data);
      } else {
        return console.log("BORKED", data);
      }
    });
    socket.on('ship:fired', function(data) {
      return socket.broadcast.emit('ship:fired', data);
    });
    socket.on('ship:exploded', function(data) {
      delete things[data.id];
      return socket.broadcast.emit('delete', data.id);
    });
    return socket.on('disconnect', function() {
      return socket.get('ship_id', function(err, ship_id) {
        delete things[ship_id];
        return socket.broadcast.emit('delete', ship_id);
      });
    });
  });

}).call(this);
