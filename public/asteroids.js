(function() {
  var Asteroid, Bullet, Exhaust, Explosion, Line, Ray, Segment, Ship, ShipObserver, Thing, World, animate, distance_between_points, socket, within;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  animate = (function() {
    var fn, _i, _len, _ref;
    _ref = ["requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      fn = _ref[_i];
      if (typeof fn === "function") {
        return fn;
      }
    }
    return function(callback) {
      return setTimeout(callback, 1000 / 60);
    };
  })();
  distance_between_points = function(a, b) {
    return ((a.x - b.x).squared() + (a.y - b.y).squared()).square_root();
  };
  within = function(a, b, delta) {
    if (delta == null) {
      delta = 0.001;
    }
    return (a - b).abs() <= delta;
  };
  Number.prototype.sign = function() {
    if (this === 0) {
      return 0;
    } else {
      if (this > 0) {
        return 1;
      } else {
        return -1;
      }
    }
  };
  Number.prototype.abs = function() {
    return Math.abs(this);
  };
  Number.prototype.squared = function() {
    return Math.pow(this, 2);
  };
  Number.prototype.square_root = function() {
    return Math.sqrt(this);
  };
  Number.prototype.arctangent = function() {
    return Math.atan(this);
  };
  Number.prototype.cosine = function() {
    return Math.cos(this);
  };
  Number.prototype.sine = function() {
    return Math.sin(this);
  };
  CanvasRenderingContext2D.prototype.line = function(from, to, options) {
    if (options == null) {
      options = {};
    }
    this.beginPath();
    this.moveTo(from.x, from.y);
    this.lineTo(to.x, to.y);
    this.closePath();
    return this.stroke();
  };
  CanvasRenderingContext2D.prototype.circle = function(at, radius, options) {
    if (options == null) {
      options = {};
    }
    this.beginPath();
    this.arc(at.x, at.y, radius, 0, 2 * Math.PI, false);
    return this.fill();
  };
  Line = (function() {
    function Line(a, b) {
      this.a = a;
      this.b = b;
    }
    Line.prototype.intersection = function(line) {
      var cross_product_a, cross_product_b, denominator;
      if (this.parallel_to(line)) {
        return;
      }
      cross_product_a = this.a.x * this.b.y - this.a.y * this.b.x;
      cross_product_b = line.a.x * line.b.y - line.a.y * line.b.x;
      denominator = (this.a.x - this.b.x) * (line.a.y - line.b.y) - (this.a.y - this.b.y) * (line.a.x - line.b.x);
      return {
        x: (cross_product_a * (line.a.x - line.b.x) - (this.a.x - this.b.x) * cross_product_b) / denominator,
        y: (cross_product_a * (line.a.y - line.b.y) - (this.a.y - this.b.y) * cross_product_b) / denominator
      };
    };
    Line.prototype.slope = function() {
      var _ref;
      return (_ref = this.slope) != null ? _ref : this.slope = (this.b.y - this.a.y) / (this.b.x - this.a.x);
    };
    Line.prototype.parallel_to = function(line) {
      return Math.abs(this.slope() - line.slope()) < 0.001;
    };
    Line.prototype.horizontal = function() {
      return Math.abs(this.a.y - this.b.y) < 0.001;
    };
    Line.prototype.vertical = function() {
      return Math.abs(this.a.x - this.b.x) < 0.001;
    };
    return Line;
  })();
  Segment = (function() {
    __extends(Segment, Line);
    function Segment() {
      Segment.__super__.constructor.apply(this, arguments);
    }
    Segment.prototype.intersection = function(line) {
      var point, _ref, _ref2;
      point = Segment.__super__.intersection.call(this, line);
      if (point) {
        if ((!this.vertical() ? (Math.min(this.a.x, this.b.x) <= (_ref = point.x) && _ref <= Math.max(this.a.x, this.b.x)) : void 0) || (!this.horizontal() ? (Math.min(this.a.y, this.b.y) <= (_ref2 = point.y) && _ref2 <= Math.max(this.a.y, this.b.y)) : void 0) || this.has_endpoint(point)) {
          return point;
        }
      }
    };
    Segment.prototype.has_endpoint = function(point) {
      return (point.x - this.a.x).abs() <= 0.001 && (point.y - this.a.y).abs() <= 0.001 || (point.x - this.b.x).abs() <= 0.001 && (point.y - this.b.y).abs() <= 0.001;
    };
    return Segment;
  })();
  Ray = (function() {
    __extends(Ray, Line);
    function Ray() {
      Ray.__super__.constructor.apply(this, arguments);
    }
    Ray.prototype.intersection = function(line) {
      var point;
      point = line instanceof Segment ? line.intersection(this) : Ray.__super__.intersection.call(this, line);
      if (point && (Math.min(this.a.x, this.b.x, point.x) === this.a.x || Math.max(this.a.x, this.b.x, point.x) === this.a.x)) {
        return point;
      }
    };
    return Ray;
  })();
  Thing = (function() {
    function Thing(options) {
      var _ref, _ref2, _ref3, _ref4;
      if (options == null) {
        options = {};
      }
      this.id = (_ref = options.id) != null ? _ref : 0;
      this.x = (_ref2 = options.x) != null ? _ref2 : 0;
      this.y = (_ref3 = options.y) != null ? _ref3 : 0;
      this.velocity = (_ref4 = options.velocity) != null ? _ref4 : {
        horizontal: 0,
        vertical: 0
      };
      this.createdAt = new Date().getTime();
    }
    Thing.prototype.update = function() {
      this.x += this.velocity.horizontal;
      return this.y += this.velocity.vertical;
    };
    Thing.prototype.position = function() {
      return {
        x: this.x,
        y: this.y
      };
    };
    return Thing;
  })();
  World = (function() {
    function World(canvas) {
      this.canvas = canvas;
      this.ctx = this.canvas.getContext('2d');
      this.things = [];
      this.bg = 'black';
      this.quadrant = {
        width: this.canvas.width / 2,
        height: this.canvas.height / 2
      };
      this.ctx.translate(this.quadrant.width, this.quadrant.height);
    }
    World.prototype.addThing = function(thing) {
      this.things.unshift(thing);
      return thing.world = this;
    };
    World.prototype.getThing = function(id) {
      var thing, _i, _len, _ref;
      _ref = this.things;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        thing = _ref[_i];
        if (thing.id === id) {
          return thing;
        }
      }
    };
    World.prototype.contains = function(thing) {
      var height, width, _ref, _ref2, _ref3, _ref4, _ref5;
      _ref3 = [this.quadrant.width + ((_ref = thing.radius) != null ? _ref : 0), this.quadrant.height + ((_ref2 = thing.radius) != null ? _ref2 : 0)], width = _ref3[0], height = _ref3[1];
      return (width > (_ref4 = thing.x) && _ref4 > -width) && (height > (_ref5 = thing.y) && _ref5 > -height);
    };
    World.prototype.drawBackground = function() {
      var i, _ref, _results, _step;
      this.ctx.fillStyle = this.bg;
      this.ctx.fillRect(-this.quadrant.width, -this.quadrant.height, this.canvas.width, this.canvas.height);
      this.ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)';
      _results = [];
      for (i = 0, _ref = Math.max(this.quadrant.height, this.quadrant.width), _step = 100; 0 <= _ref ? i <= _ref : i >= _ref; i += _step) {
        this.ctx.line({
          x: i,
          y: -this.quadrant.height
        }, {
          x: i,
          y: this.quadrant.height
        });
        this.ctx.line({
          x: -this.quadrant.width,
          y: i
        }, {
          x: this.quadrant.width,
          y: i
        });
        _results.push(i ? (this.ctx.line({
          x: -i,
          y: -this.quadrant.height
        }, {
          x: -i,
          y: this.quadrant.height
        }), this.ctx.line({
          x: -this.quadrant.width,
          y: -i
        }, {
          x: this.quadrant.width,
          y: -i
        })) : void 0);
      }
      return _results;
    };
    World.prototype.render = function() {
      var other, thing, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4;
      this.now = new Date().getTime();
      this.drawBackground();
      _ref = this.things;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        thing = _ref[_i];
        this.ctx.save();
        thing.update();
        if (thing.wrap) {
          if (!((this.quadrant.width > (_ref2 = thing.x) && _ref2 > -this.quadrant.width))) {
            thing.x = this.quadrant.width * -thing.x.sign();
          }
          if (!((this.quadrant.height > (_ref3 = thing.y) && _ref3 > -this.quadrant.height))) {
            thing.y = this.quadrant.height * -thing.y.sign();
          }
        } else {
          if (!this.contains(thing)) {
            thing.cull = true;
          }
        }
        this.ctx.translate(thing.x, thing.y);
        thing.render(this.ctx);
        if (thing instanceof Ship) {
          _ref4 = this.things;
          for (_j = 0, _len2 = _ref4.length; _j < _len2; _j++) {
            other = _ref4[_j];
            if (other === thing) {
              continue;
            }
            if (typeof thing.collides_with === "function" ? thing.collides_with(other) : void 0) {
              if (typeof thing.collided_with === "function") {
                thing.collided_with(other);
              }
              if (typeof other.collided_with === "function") {
                other.collided_with(thing);
              }
            }
          }
        }
        this.ctx.restore();
      }
      this.things = this.things.filter(function(thing) {
        return !thing.cull;
      });
      return animate(__bind(function() {
        return this.render();
      }, this));
    };
    return World;
  })();
  Ship = (function() {
    __extends(Ship, Thing);
    function Ship(options) {
      var _ref, _ref2, _ref3;
      if (options == null) {
        options = {};
      }
      Ship.__super__.constructor.call(this, options);
      this.color = (_ref = options.color) != null ? _ref : {
        r: 0,
        g: 255,
        b: 0
      };
      this.angle = (_ref2 = options.angle) != null ? _ref2 : 0;
      this.maxSpeed = (_ref3 = options.maxSpeed) != null ? _ref3 : 7;
      this.thrusters = null;
      this.wrap = true;
    }
    Ship.prototype.update = function() {
      if (this.thrusters) {
        this.accelerate();
      }
      return Ship.__super__.update.call(this);
    };
    Ship.prototype.render = function(ctx) {
      ctx.rotate(this.angle);
      ctx.beginPath();
      ctx.moveTo(10, 0);
      ctx.lineTo(-10, 7);
      ctx.lineTo(-10, -7);
      ctx.lineTo(10, 0);
      ctx.closePath();
      ctx.strokeStyle = "rgb(" + this.color.r + ", " + this.color.g + ", " + this.color.b + ")";
      ctx.fillStyle = "rgba(" + this.color.r + ", " + this.color.g + ", " + this.color.b + ", 0.67)";
      ctx.lineWidth = 2;
      ctx.lineJoin = 'round';
      ctx.stroke();
      return ctx.fill();
    };
    Ship.prototype.fireThrusters = function() {
      var thrust;
      thrust = __bind(function() {
        return this.world.addThing(new Exhaust({
          x: this.x - 10 * Math.cos(this.angle),
          y: this.y - 10 * Math.sin(this.angle)
        }));
      }, this);
      if (!this.thrusters) {
        thrust();
      }
      if (!this.thrusters) {
        return this.thrusters = setInterval(thrust, 100);
      }
    };
    Ship.prototype.stopThrusters = function() {
      clearInterval(this.thrusters);
      return this.thrusters = null;
    };
    Ship.prototype.accelerate = (function() {
      var throttler, timeout;
      timeout = null;
      throttler = function() {
        var hypotenuse, hypotenuseSquared;
        this.velocity.horizontal += Math.cos(this.angle);
        this.velocity.vertical += Math.sin(this.angle);
        if ((hypotenuseSquared = Math.pow(this.velocity.horizontal, 2) + Math.pow(this.velocity.vertical, 2)) > Math.pow(this.maxSpeed, 2)) {
          hypotenuse = Math.sqrt(hypotenuseSquared);
          this.velocity.horizontal = this.maxSpeed * this.velocity.horizontal / hypotenuse;
          this.velocity.vertical = this.maxSpeed * this.velocity.vertical / hypotenuse;
        }
        publish('ship:moved', [this]);
        return timeout = setTimeout((function() {
          return timeout = null;
        }), 250);
      };
      return function() {
        if (!timeout) {
          return throttler.call(this);
        }
      };
    })();
    Ship.prototype.turnLeft = function() {
      this.angle -= Math.PI / 12;
      return publish('ship:moved', [this]);
    };
    Ship.prototype.turnRight = function() {
      this.angle += Math.PI / 12;
      return publish('ship:moved', [this]);
    };
    Ship.prototype.fire = (function() {
      var throttler, timeout;
      timeout = null;
      throttler = function() {
        var bullet;
        bullet = new Bullet({
          x: this.x + 10 * Math.cos(this.angle),
          y: this.y + 10 * Math.sin(this.angle),
          lifespan: 10000,
          velocity: {
            horizontal: 10 * Math.cos(this.angle),
            vertical: 10 * Math.sin(this.angle)
          }
        });
        this.world.addThing(bullet);
        publish('ship:fired', [this, bullet]);
        return timeout = setTimeout((function() {
          return timeout = null;
        }), 1000);
      };
      return function() {
        if (!timeout) {
          return throttler.call(this);
        }
      };
    })();
    Ship.prototype.explode = function() {
      this.cull = true;
      return this.world.addThing(new Explosion({
        x: this.x,
        y: this.y
      }));
    };
    Ship.prototype.collides_with = function(thing) {
      if (thing instanceof Bullet) {
        return distance_between_points(this.position(), thing.position()) < 10;
      } else {
        return typeof thing.contains === "function" ? thing.contains({
          x: this.x,
          y: this.y
        }) : void 0;
      }
    };
    Ship.prototype.collided_with = function(thing) {
      return this.explode();
    };
    Ship.prototype.reset = function() {
      this.x = 0;
      this.y = 0;
      this.angle = 0;
      return this.velocity = {
        horizontal: 0,
        vertical: 0
      };
    };
    return Ship;
  })();
  Exhaust = (function() {
    __extends(Exhaust, Thing);
    function Exhaust(options) {
      var _ref;
      if (options == null) {
        options = {};
      }
      Exhaust.__super__.constructor.call(this, options);
      this.lifespan = (_ref = options.lifespan) != null ? _ref : 1000;
    }
    Exhaust.prototype.update = function() {
      var percentCompleted;
      percentCompleted = (this.world.now - this.createdAt) / this.lifespan;
      this.alpha = 1 - percentCompleted;
      this.radius = 1 + 6 * percentCompleted;
      if (this.alpha < 0.01) {
        return this.cull = true;
      }
    };
    Exhaust.prototype.render = function(ctx) {
      ctx.fillStyle = "rgba(255, 100, 200, " + this.alpha + ")";
      return ctx.circle({
        x: 0,
        y: 0
      }, this.radius);
    };
    return Exhaust;
  })();
  Bullet = (function() {
    __extends(Bullet, Thing);
    function Bullet() {
      Bullet.__super__.constructor.apply(this, arguments);
    }
    Bullet.prototype.render = function(ctx) {
      ctx.fillStyle = "white";
      return ctx.circle({
        x: 0,
        y: 0
      }, 2);
    };
    Bullet.prototype.collides_with = function(thing) {
      return typeof thing.contains === "function" ? thing.contains({
        x: this.x,
        y: this.y
      }) : void 0;
    };
    Bullet.prototype.collided_with = function(thing) {
      if (thing instanceof Asteroid && !this.cull) {
        this.world.addThing(new Explosion({
          x: this.x,
          y: this.y,
          duration: 250,
          radius: 20,
          color: {
            r: 255,
            g: 239,
            b: 0
          }
        }));
      }
      return this.cull = true;
    };
    return Bullet;
  })();
  Explosion = (function() {
    __extends(Explosion, Thing);
    function Explosion(options) {
      var _ref, _ref2, _ref3;
      if (options == null) {
        options = {};
      }
      Explosion.__super__.constructor.call(this, options);
      this.maxRadius = (_ref = options.radius) != null ? _ref : 100;
      this.duration = (_ref2 = options.duration) != null ? _ref2 : 500;
      this.color = (_ref3 = options.color) != null ? _ref3 : {
        r: 255,
        g: 64,
        b: 0
      };
    }
    Explosion.prototype.update = function() {
      var elapsed;
      Explosion.__super__.update.call(this);
      elapsed = +(new Date()) - this.createdAt;
      this.radius = this.maxRadius * elapsed / this.duration;
      this.opacity = 1.0 - elapsed / this.duration;
      if (elapsed > this.duration) {
        return this.cull = true;
      }
    };
    Explosion.prototype.render = function(ctx) {
      ctx.fillStyle = "rgba(" + this.color.r + ", " + this.color.g + ", " + this.color.b + ", " + this.opacity + ")";
      return ctx.circle({
        x: 0,
        y: 0
      }, this.radius);
    };
    return Explosion;
  })();
  Asteroid = (function() {
    __extends(Asteroid, Thing);
    function Asteroid(options) {
      var _ref, _ref2, _ref3;
      if (options == null) {
        options = {};
      }
      Asteroid.__super__.constructor.call(this, options);
      this.radius = (_ref = options.radius) != null ? _ref : 50;
      this.sides = (_ref2 = options.sides) != null ? _ref2 : 5;
      this.angle = 0;
      this.rateOfRotation = (_ref3 = options.rateOfRotation) != null ? _ref3 : 120;
      this.strokeStyle = "rgb(200, 200, 200)";
      this.fillStyle = "rgba(200, 200, 200, 0.67)";
    }
    Asteroid.prototype.update = function() {
      Asteroid.__super__.update.call(this);
      return this.angle += Math.PI / this.rateOfRotation;
    };
    Asteroid.prototype.render = function(ctx) {
      var angle, side, x, y, _ref, _ref2, _ref3;
      angle = this.angle;
      ctx.beginPath();
      _ref = [this.radius * Math.cos(angle), this.radius * Math.sin(angle)], x = _ref[0], y = _ref[1];
      this.points = [
        {
          x: this.x + x,
          y: this.y + y
        }
      ];
      ctx.moveTo(x, y);
      for (side = 1, _ref2 = this.sides; 1 <= _ref2 ? side < _ref2 : side > _ref2; 1 <= _ref2 ? side++ : side--) {
        angle += 2 * Math.PI / this.sides;
        _ref3 = [this.radius * Math.cos(angle), this.radius * Math.sin(angle)], x = _ref3[0], y = _ref3[1];
        this.points.push({
          x: this.x + x,
          y: this.y + y
        });
        ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.strokeStyle = this.strokeStyle;
      ctx.fillStyle = this.fillStyle;
      ctx.stroke();
      return ctx.fill();
    };
    Asteroid.prototype.contains = function(point) {
      var current_position, intersection, intersections, ray, segment, unique, _i, _j, _len, _len2, _ref;
      current_position = this.position();
      if (distance_between_points(point, current_position) > this.radius) {
        return false;
      }
      ray = new Ray(point, current_position);
      intersections = [];
      _ref = this.segments();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        segment = _ref[_i];
        point = ray.intersection(segment);
        if (point) {
          unique = true;
          for (_j = 0, _len2 = intersections.length; _j < _len2; _j++) {
            intersection = intersections[_j];
            if (Math.abs(point.x - intersection.x) < 0.001 && Math.abs(point.y - intersection.y) < 0.001) {
              unique = false;
              break;
            }
          }
          if (unique) {
            intersections.push(point);
          }
        }
      }
      return intersections.length > 0 && intersections.length % 2;
    };
    Asteroid.prototype.segments = function() {
      var index, _ref, _results;
      _results = [];
      for (index = 0, _ref = this.points.length; 0 <= _ref ? index < _ref : index > _ref; 0 <= _ref ? index++ : index--) {
        _results.push(new Segment(this.points[index], this.points[(index + 1) % this.points.length]));
      }
      return _results;
    };
    Asteroid.prototype.collided_with = function(thing) {
      if (thing instanceof Bullet) {
        this.radius -= 10;
        if (this.radius <= 50) {
          return this.cull = true;
        }
      }
    };
    return Asteroid;
  })();
  ShipObserver = (function() {
    function ShipObserver(socket) {
      this.socket = socket;
      subscribe('ship:moved', __bind(function(ship) {
        return this.moved(ship);
      }, this));
      subscribe('ship:fired', __bind(function(ship, bullet) {
        return this.fired(ship, bullet);
      }, this));
    }
    ShipObserver.prototype.moved = function(ship) {
      var data;
      data = {
        id: ship.id,
        position: ship.position(),
        angle: ship.angle,
        velocity: ship.velocity
      };
      return this.socket.emit('update', data);
    };
    ShipObserver.prototype.fired = function(ship, bullet) {
      var data;
      data = {
        position: bullet.position(),
        velocity: bullet.velocity
      };
      return this.socket.emit('ship:fired', data);
    };
    return ShipObserver;
  })();
  socket = io.connect("/");
  document.addEventListener('DOMContentLoaded', (function() {
    var canvas, ship, shipObserver, world;
    canvas = document.getElementsByTagName('canvas')[0];
    world = new World(canvas);
    ship = null;
    shipObserver = new ShipObserver(socket);
    socket.on('add', function(things) {
      var data, id, thing, _results;
      _results = [];
      for (id in things) {
        data = things[id];
        thing = new Ship(data);
        world.addThing(thing);
        _results.push(data.yours ? ship = thing : void 0);
      }
      return _results;
    });
    socket.on('update', function(data) {
      var thing;
      thing = world.getThing(data.id);
      thing.x = data.position.x;
      thing.y = data.position.y;
      thing.angle = data.angle;
      return thing.velocity = data.velocity;
    });
    socket.on('ship:fired', function(data) {
      console.log(data);
      return world.addThing(new Bullet({
        x: data.position.x,
        y: data.position.y,
        velocity: data.velocity,
        lifespan: 10000
      }));
    });
    socket.on('delete', function(id) {
      var thing;
      thing = world.getThing(id);
      return typeof thing.explode === "function" ? thing.explode() : void 0;
    });
    document.addEventListener('keydown', (function(event) {
      var charCode;
      if (!ship) {
        return;
      }
      charCode = String.fromCharCode(event.which);
      if (charCode === 'W' || charCode === 'A' || charCode === 'D' || charCode === ' ') {
        event.preventDefault();
        switch (String.fromCharCode(event.which)) {
          case 'W':
            return ship.fireThrusters();
          case 'A':
            return ship.turnLeft();
          case 'D':
            return ship.turnRight();
          case ' ':
            return ship.fire();
        }
      }
    }), false);
    setInterval((function() {
      if (!ship) {
        return;
      }
      return publish('ship:moved', [ship]);
    }), 1000);
    document.addEventListener('keyup', (function(event) {
      if (!ship) {
        return;
      }
      switch (String.fromCharCode(event.which)) {
        case 'W':
          return ship.stopThrusters();
      }
    }), false);
    return animate(function() {
      return world.render();
    });
  }), false);
}).call(this);
