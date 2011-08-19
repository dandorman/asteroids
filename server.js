(function() {
  var app, cycle, express, io, next_thing_id, port, ship_colors, things;
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
    return port = 3000;
  });
  app.get('/', function(req, res) {
    return res.render('index.coffee');
  });
  io = require('socket.io').listen(app);
  app.listen(port);
  cycle = function(items) {
    var index, length, _ref;
    _ref = [0, items.length], index = _ref[0], length = _ref[1];
    return {
      next: function() {
        return items[index++ % length];
      }
    };
  };
  ship_colors = cycle([
    {
      r: 0,
      g: 255,
      b: 0
    }, {
      r: 255,
      g: 0,
      b: 0
    }, {
      r: 0,
      g: 0,
      b: 255
    }
  ]);
  things = {};
  next_thing_id = 0;
  io.sockets.on('connection', function(socket) {
    var new_thing, tmp;
    new_thing = {
      id: ++next_thing_id,
      x: 0,
      y: 0,
      color: ship_colors.next(),
      maxSpeed: 3
    };
    things[next_thing_id] = new_thing;
    tmp = {};
    tmp[next_thing_id] = new_thing;
    socket.broadcast.emit('add', tmp);
    new_thing.yours = true;
    socket.emit('add', things);
    delete new_thing.yours;
    return socket.on('update', function(data) {
      var thing;
      thing = things[data.id];
      thing.x = data.position.x;
      thing.y = data.position.y;
      thing.angle = data.angle;
      thing.velocity = data.velocity;
      return socket.broadcast.emit('update', data);
    });
  });
}).call(this);
