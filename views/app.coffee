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

  class World
    constructor: (@canvas) ->
      @ctx = @canvas.getContext '2d'
      @things = []

      @bg = 'black'

      @quadrant =
        width: @canvas.width / 2
        height: @canvas.height / 2

      @ctx.translate @quadrant.width, @quadrant.height

    addThing: (thing) ->
      @things.unshift thing
      thing.world = this

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

      for thing in @things
        @ctx.save()

        thing.update()
        thing.x = @quadrant.width * -thing.x.sign() unless @quadrant.width > thing.x > -@quadrant.width
        thing.y = @quadrant.height * -thing.y.sign() unless @quadrant.height > thing.y > -@quadrant.height

        @ctx.translate thing.x, thing.y
        thing.render @ctx

        @ctx.restore()

  class Ship
    constructor: (options = {}) ->
      @x = options.x ? 0
      @y = options.y ? 0
      @angle = options.angle ? 0
      @maxSpeed = options.maxSpeed ? 7

      @thrusters = null
      @velocity =
        horizontal: 0
        vertical: 0

    update: ->
      @accelerate() if @thrusters
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
      thrust = =>
        @world.addThing new Spark {x: @x - 10 * Math.cos(@angle), y: @y - 10 * Math.sin(@angle)}
      thrust() unless @thrusters
      @thrusters = setInterval thrust, 100 unless @thrusters

    stopThrusters: ->
      clearInterval(@thrusters)
      @thrusters= null

    accelerate: do ->
      timeout = null
      ->
        throttler = =>
          timeout = null

          @velocity.horizontal += Math.cos @angle
          @velocity.vertical += Math.sin @angle

          if (hypotenuseSquared = Math.pow(@velocity.horizontal, 2) + Math.pow(@velocity.vertical, 2)) > Math.pow(@maxSpeed, 2)
            hypotenuse = Math.sqrt hypotenuseSquared
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

  class Spark
    constructor: (options = {}) ->
      @x = options.x ? 0
      @y = options.y ? 0

      @duration = options.duration ? 1000

      @createdAt = new Date().getTime()
      @logged = false

    update: ->
      @alpha = 1 - (new Date().getTime() - @createdAt) / @duration

    render: (ctx) ->
      ctx.strokeStyle = "rgba(255, 100, 200, #{@alpha})"
      ctx.lineWidth = 2
      ctx.line {x: -1, y: -1}, {x: 1, y: 1}

  class X
    constructor: (options = {}) ->
      @x = options.x ? 0
      @y = options.y ? 0
      @color = options.color ? "white"
      @size = options.size ? 5

    update: ->

    render: (ctx) ->
      ctx.strokeStyle = @color
      ctx.lineWidth = 1

      ctx.line {x: -@size, y: -@size}, {x: @size, y: @size}
      ctx.line {x: -@size, y: @size}, {x: @size, y: -@size}


  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas
  ship = new Ship({x: 0, y: 0})
  world.addThing ship

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
    world.render()
  ), 1000 / 60
), false
