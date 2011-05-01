document.addEventListener('DOMContentLoaded', function() {
  function Scene(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.objects = [];

    this.bg = 'black';

    this.ctx.translate(canvas.width / 2, canvas.height / 2);
  }

  Scene.prototype.addObject = function(object) {
    this.objects.push(object);
  };

  Scene.prototype.drawBackground = function() {
    this.ctx.fillStyle = this.bg;
    this.ctx.fillRect(-(this.canvas.width / 2), -(this.canvas.height / 2), this.canvas.width, this.canvas.height);

    this.ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)';
    for (var i = 0, l = Math.max(this.canvas.height / 2, this.canvas.width / 2); i < l; i += 100) {
      this.ctx.beginPath();
      this.ctx.moveTo(i, -(this.canvas.height / 2));
      this.ctx.lineTo(i, this.canvas.height / 2);
      this.ctx.closePath();
      this.ctx.stroke();

      this.ctx.beginPath();
      this.ctx.moveTo(-(this.canvas.width / 2), i);
      this.ctx.lineTo(this.canvas.width / 2, i);
      this.ctx.closePath();
      this.ctx.stroke();

      if (i) {
        this.ctx.beginPath();
        this.ctx.moveTo(-i, -(this.canvas.height / 2));
        this.ctx.lineTo(-i, this.canvas.height / 2);
        this.ctx.closePath();
        this.ctx.stroke();

        this.ctx.beginPath();
        this.ctx.moveTo(-(this.canvas.width / 2), -i);
        this.ctx.lineTo(this.canvas.width / 2, -i);
        this.ctx.closePath();
        this.ctx.stroke();
      }
    }
  };

  Scene.prototype.render = function() {
    this.drawBackground();

    for (var i = 0, l = this.objects.length; i < l; i++) {
      this.ctx.save();

      this.objects[i].update();
      if (this.objects[i].x < -(this.canvas.width / 2)) {
        this.objects[i].x = this.canvas.width / 2;
      }
      if (this.objects[i].x > (this.canvas.width / 2)) {
        this.objects[i].x = -(this.canvas.width / 2);
      }
      if (this.objects[i].y < -(this.canvas.height / 2)) {
        this.objects[i].y = this.canvas.height / 2;
      }
      if (this.objects[i].y > (this.canvas.height / 2)) {
        this.objects[i].y = -(this.canvas.height / 2);
      }

      this.ctx.translate(this.objects[i].x, this.objects[i].y);
      this.objects[i].render(this.ctx);

      this.ctx.restore();
    }
  };

  function Ship(options) {
    options = options || {};

    this.x = options.x || 0;
    this.y = options.y || 0;
    this.angle = options.angle || 0;
    this.maxSpeed = options.maxSpeed || 5;

    this.velocity = {horizontal: 0, vertical: 0};
  }

  Ship.prototype.update = function() {
    this.x += this.velocity.horizontal;
    this.y += this.velocity.vertical;
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
    ctx.fillStyle = 'rgba(0, 255, 0, 0.33)';
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.fill();
  };

  Ship.prototype.thrust = function() {
    this.velocity.horizontal += Math.cos(this.angle);
    this.velocity.vertical += Math.sin(this.angle);

    if (Math.pow(this.velocity.horizontal, 2) + Math.pow(this.velocity.vertical, 2) > Math.pow(this.maxSpeed, 2)) {
      var hypotenuse = Math.sqrt(Math.pow(this.velocity.horizontal, 2) + Math.pow(this.velocity.vertical, 2));
      this.velocity.horizontal = this.maxSpeed * this.velocity.horizontal / hypotenuse;
      this.velocity.vertical = this.maxSpeed * this.velocity.vertical / hypotenuse;
    }
  };

  Ship.prototype.turnLeft = function() {
    this.angle -= Math.PI / 12;
  };

  Ship.prototype.turnRight = function() {
    this.angle += Math.PI / 12;
  };

  var canvas = document.getElementsByTagName('canvas')[0];
  canvas.height = window.innerHeight;
  canvas.width = window.innerWidth;

  scene = new Scene(canvas);
  ship = new Ship();
  scene.addObject(ship);

  document.addEventListener('keydown', function(event) {
    switch (String.fromCharCode(event.which)) {
      case 'W':
        ship.thrust();
        break;

      case 'A':
        ship.turnLeft();
        break;

      case 'D':
        ship.turnRight();
        break;

      case 'X':
        ship.x = 0;
        ship.y = 0;
        ship.angle = 0;
        ship.velocity = {horizontal: 0, vertical: 0};
        break;
    }
  }, false);

  if ('createTouch' in document) {
    document.addEventListener('touchstart', function(event) {
    });
  }

  setInterval(function() {
    scene.render();
  }, 1000 / 60);
}, false);

