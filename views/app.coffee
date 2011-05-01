document.addEventListener 'DOMContentLoaded', (->
  Number::sign = ->
    if this is 0
      0
    else
      if this > 0 then 1 else -1

  CanvasRenderingContext2D::line = (from, to, options = {}) ->
    @beginPath()
    @moveTo from.x, from.y
    @lineTo to.x, to.y
    @closePath()
    @stroke()

  class Scene
    constructor: (@canvas) ->
      @ctx = @canvas.getContext '2d'
      @objects = []

      @bg = 'black'

      @quadrant =
        width: @canvas.width / 2
        height: @canvas.height / 2

      @ctx.translate @quadrant.width, @quadrant.height

    drawBackground: ->
      @ctx.fillStyle = @bg
      @ctx.fillRect -@quadrant.width, -@quadrant.height, @canvas.width, @canvas.height

      @ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)'
      for i in [0..Math.max(@quadrant.height, @quadrant.width)] by 100
        @ctx.line {x: i, y: -@quadrant.height}, {x: i, y: @quadrant.height}
        @ctx.line {x: -@quadrant.width, y: i}, {x: @quadrant.width, y: i}

        if i
          @ctx.line {x: -i, y: -@quadrant.height}, {x: -i, y: @quadrant.height}
          @ctx.line {x: -@quadrant.width, y: -i}, {x: @quadrant.width, y: -i}

    render: ->
      @drawBackground()

      for object in @objects
        @ctx.save()

        object.update()
        object.x = @quadrant.width * -object.x.sign() unless @quadrant.width > object.x > -@quadrant.width
        object.y = @quadrant.height * -object.y.sign() unless @quadrant.height > object.y > -@quadrant.height

        @ctx.translate object.x, object.y
        object.render @ctx

        @ctx.restore()

  class Ship
    constructor: (options = {}) ->
      @x = options.x ? 0
      @y = options.y ? 0
      @angle = options.angle ? 0
      @maxSpeed = options.maxSpeed ? 7

      @thrusters = off
      @velocity =
        horizontal: 0
        vertical: 0

    update: ->
      @accelerate() if @thrusters is on
      @x += @velocity.horizontal
      @y += @velocity.vertical

    render: (ctx) ->
      ctx.rotate @angle

      ctx.beginPath()
      ctx.moveTo 10, 0
      ctx.lineTo -10, 7
      ctx.lineTo -10, -7
      ctx.lineTo 10, 0
      ctx.closePath()

      ctx.strokeStyle = 'rgb(0, 255, 0)'
      ctx.fillStyle = 'rgba(0, 255, 0, 0.67)'
      ctx.lineWidth = 2
      ctx.lineJoin = 'round'
      ctx.stroke()
      ctx.fill()

    fireThrusters: ->
      @thrusters = on

    stopThrusters: ->
      @thrusters = off

    accelerate: do ->
      timeout = null
      ->
        throttler = =>
          timeout = null

          @velocity.horizontal += Math.cos @angle
          @velocity.vertical += Math.sin @angle

          if (hypotenuse_squared = Math.pow(@velocity.horizontal, 2) + Math.pow(@velocity.vertical, 2)) > Math.pow(@maxSpeed, 2)
            hypotenuse = Math.sqrt hypotenuse_squared
            @velocity.horizontal = @maxSpeed * @velocity.horizontal / hypotenuse
            @velocity.vertical = @maxSpeed * @velocity.vertical / hypotenuse

        timeout = setTimeout throttler, 250 unless timeout

    turnLeft: -> @angle -= Math.PI / 12

    turnRight: -> @angle += Math.PI / 12

    reset: ->
      @x = 0
      @y = 0
      @angle = 0
      @velocity =
        horizontal: 0
        vertical: 0

  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  scene = new Scene canvas
  ship = new Ship()
  scene.objects.push ship

  document.addEventListener 'keydown', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.fireThrusters()
      when 'A' then ship.turnLeft()
      when 'D' then ship.turnRight()
      when 'X' then ship.reset()
  ), false

  document.addEventListener 'keyup', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.stopThrusters()
  ), false

  setInterval (->
    scene.render()
  ), 1000 / 60
), false
