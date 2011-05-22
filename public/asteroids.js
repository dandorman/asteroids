(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  document.addEventListener('DOMContentLoaded', (function() {
    var Asteroid, Bullet, Exhaust, Ship, Thing, World, X, animate, asteroid, canvas, ship, world;
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
      World.prototype.contains = function(thing) {
        var _ref, _ref2;
        return (this.quadrant.width > (_ref = thing.x) && _ref > -this.quadrant.width) && (this.quadrant.height > (_ref2 = thing.y) && _ref2 > -this.quadrant.height);
      };
      World.prototype.drawBackground = function() {
        var i, _ref, _results;
        this.ctx.fillStyle = this.bg;
        this.ctx.fillRect(-this.quadrant.width, -this.quadrant.height, this.canvas.width, this.canvas.height);
        this.ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)';
        _results = [];
        for (i = 0, _ref = Math.max(this.quadrant.height, this.quadrant.width); 0 <= _ref ? i <= _ref : i >= _ref; i += 100) {
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
              if (other instanceof Ship) {
                break;
              }
              if (ship.collides_with(other)) {
                console.log("collision!");
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
    Thing = (function() {
      function Thing(options) {
        var _ref;
        if (options == null) {
          options = {};
        }
        this.x = options.x;
        this.y = options.y;
        this.velocity = (_ref = options.velocity) != null ? _ref : {
          horizontal: 0,
          vertical: 0
        };
        this.createdAt = new Date().getTime();
      }
      Thing.prototype.update = function() {
        this.x += this.velocity.horizontal;
        return this.y += this.velocity.vertical;
      };
      Thing.prototype.contains = function() {
        return false;
      };
      return Thing;
    })();
    Ship = (function() {
      function Ship(options) {
        var _ref, _ref2;
        if (options == null) {
          options = {};
        }
        Ship.__super__.constructor.call(this, options);
        this.angle = (_ref = options.angle) != null ? _ref : 0;
        this.maxSpeed = (_ref2 = options.maxSpeed) != null ? _ref2 : 7;
        this.thrusters = null;
        this.wrap = true;
      }
      __extends(Ship, Thing);
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
        ctx.strokeStyle = 'rgb(0, 255, 0)';
        ctx.fillStyle = 'rgba(0, 255, 0, 0.67)';
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
        var timeout;
        timeout = null;
        return function() {
          var throttler;
          throttler = __bind(function() {
            var hypotenuse, hypotenuseSquared;
            timeout = null;
            this.velocity.horizontal += Math.cos(this.angle);
            this.velocity.vertical += Math.sin(this.angle);
            if ((hypotenuseSquared = Math.pow(this.velocity.horizontal, 2) + Math.pow(this.velocity.vertical, 2)) > Math.pow(this.maxSpeed, 2)) {
              hypotenuse = Math.sqrt(hypotenuseSquared);
              this.velocity.horizontal = this.maxSpeed * this.velocity.horizontal / hypotenuse;
              return this.velocity.vertical = this.maxSpeed * this.velocity.vertical / hypotenuse;
            }
          }, this);
          if (!timeout) {
            return timeout = setTimeout(throttler, 250);
          }
        };
      })();
      Ship.prototype.turnLeft = function() {
        return this.angle -= Math.PI / 12;
      };
      Ship.prototype.turnRight = function() {
        return this.angle += Math.PI / 12;
      };
      Ship.prototype.fire = function() {
        return this.world.addThing(new Bullet({
          x: this.x + 10 * Math.cos(this.angle),
          y: this.y + 10 * Math.sin(this.angle),
          lifespan: 10000,
          velocity: {
            horizontal: 10 * Math.cos(this.angle),
            vertical: 10 * Math.sin(this.angle)
          }
        }));
      };
      Ship.prototype.collides_with = function(thing) {
        if (thing.contains({
          x: this.x,
          y: this.y
        })) {
          return true;
        } else {
          return false;
        }
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
      function Exhaust(options) {
        var _ref;
        if (options == null) {
          options = {};
        }
        Exhaust.__super__.constructor.call(this, options);
        this.lifespan = (_ref = options.lifespan) != null ? _ref : 1000;
      }
      __extends(Exhaust, Thing);
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
      function Bullet() {
        Bullet.__super__.constructor.apply(this, arguments);
      }
      __extends(Bullet, Thing);
      Bullet.prototype.render = function(ctx) {
        ctx.fillStyle = "white";
        return ctx.circle({
          x: 0,
          y: 0
        }, 2);
      };
      return Bullet;
    })();
    Asteroid = (function() {
      function Asteroid(options) {
        var _ref, _ref2;
        if (options == null) {
          options = {};
        }
        Asteroid.__super__.constructor.call(this, options);
        this.radius = (_ref = options.radius) != null ? _ref : 50;
        this.sides = (_ref2 = options.sides) != null ? _ref2 : 5;
      }
      __extends(Asteroid, Thing);
      Asteroid.prototype.render = function(ctx) {
        var angle, side, x, y, _ref, _ref2, _ref3;
        angle = 0;
        ctx.beginPath();
        _ref = [this.radius * Math.cos(angle), this.radius * Math.sin(angle)], x = _ref[0], y = _ref[1];
        ctx.moveTo(x, y);
        for (side = 1, _ref2 = this.sides; 1 <= _ref2 ? side < _ref2 : side > _ref2; 1 <= _ref2 ? side++ : side--) {
          angle += 2 * Math.PI / this.sides;
          _ref3 = [this.radius * Math.cos(angle), this.radius * Math.sin(angle)], x = _ref3[0], y = _ref3[1];
          ctx.lineTo(x, y);
        }
        ctx.closePath();
        ctx.strokeStyle = "rgb(200, 200, 200)";
        ctx.fillStyle = "rgba(200, 200, 200, 0.67)";
        ctx.stroke();
        return ctx.fill();
      };
      Asteroid.prototype.contains = function(point) {
        return Math.sqrt(Math.pow(this.x - point.x, 2) + Math.pow(this.y - point.y, 2)) <= this.radius;
      };
      return Asteroid;
    })();
    X = (function() {
      function X(options) {
        var _ref, _ref2;
        if (options == null) {
          options = {};
        }
        X.__super__.constructor.call(this, options);
        this.color = (_ref = options.color) != null ? _ref : "white";
        this.size = (_ref2 = options.size) != null ? _ref2 : 5;
      }
      __extends(X, Thing);
      X.prototype.render = function(ctx) {
        ctx.strokeStyle = this.color;
        ctx.lineWidth = 1;
        ctx.line({
          x: -this.size,
          y: -this.size
        }, {
          x: this.size,
          y: this.size
        });
        return ctx.line({
          x: -this.size,
          y: this.size
        }, {
          x: this.size,
          y: -this.size
        });
      };
      return X;
    })();
    canvas = document.getElementsByTagName('canvas')[0];
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
    world = new World(canvas);
    ship = new Ship({
      x: 0,
      y: 0,
      maxSpeed: 3
    });
    world.addThing(ship);
    asteroid = new Asteroid({
      x: -200,
      y: -175
    });
    world.addThing(asteroid);
    document.addEventListener('keydown', (function(event) {
      switch (String.fromCharCode(event.which)) {
        case 'W':
          return ship.fireThrusters();
        case 'A':
          return ship.turnLeft();
        case 'D':
          return ship.turnRight();
        case 'X':
          return ship.reset();
        case ' ':
          return ship.fire();
      }
    }), false);
    document.addEventListener('keyup', (function(event) {
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
