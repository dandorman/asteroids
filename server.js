(function() {
  var app, cycle, express, field_height, field_width, io, next_thing_id, port, ship_colors, things, _ref;

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

  _ref = [750, 750], field_width = _ref[0], field_height = _ref[1];

  io.sockets.on('connection', function(socket) {
    var new_thing, tmp;
    new_thing = {
      id: ++next_thing_id,
      x: Math.floor(field_width / 2),
      y: Math.floor(field_height / 2),
      color: ship_colors.next(),
      maxSpeed: 3
    };
    things[next_thing_id] = new_thing;
    tmp = {};
    tmp[next_thing_id] = new_thing;
    socket.broadcast.emit('add', tmp);
    new_thing.yours = true;
    socket.emit('add', things);
    socket.set('ship_id', next_thing_id);
    delete new_thing.yours;
    socket.on('update', function(data) {
      var thing;
      thing = things[data.id];
      thing.x = data.position.x;
      thing.y = data.position.y;
      thing.angle = data.angle;
      thing.velocity = data.velocity;
      return socket.broadcast.emit('update', data);
    });
    socket.on('ship:fired', function(data) {
      return socket.broadcast.emit('ship:fired', data);
    });
    return socket.on('disconnect', function() {
      return socket.get('ship_id', function(err, ship_id) {
        delete things[ship_id];
        return socket.broadcast.emit('delete', ship_id);
      });
    });
  });

}).call(this);
