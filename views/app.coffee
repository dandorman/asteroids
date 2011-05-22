document.addEventListener 'DOMContentLoaded', (->
  animate = do ->
    for fn in ["requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame"]
      return fn if typeof fn is "function"
    (callback) -> setTimeout(callback, 1000 / 60)

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

  CanvasRenderingContext2D::circle = (at, radius, options = {}) ->
    @beginPath()
    @arc(at.x, at.y, radius, 0, 2 * Math.PI, false)
    @fill()

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

    contains: (thing) ->
      @quadrant.width > thing.x > -@quadrant.width and @quadrant.height > thing.y > -@quadrant.height

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
      @now = new Date().getTime()

      @drawBackground()

      for thing in @things
        @ctx.save()

        thing.update()
        if thing.wrap
          thing.x = @quadrant.width * -thing.x.sign() unless @quadrant.width > thing.x > -@quadrant.width
          thing.y = @quadrant.height * -thing.y.sign() unless @quadrant.height > thing.y > -@quadrant.height
        else
          thing.cull = true unless @contains thing

        @ctx.translate thing.x, thing.y
        thing.render @ctx

        if thing instanceof Ship
          for other in @things
            break if other instanceof Ship
            console.log("collision!") if ship.collides_with(other)

        @ctx.restore()

      @things = @things.filter (thing) -> not thing.cull

      animate => @render()

  class Thing
    constructor: (options = {}) ->
      @x = options.x
      @y = options.y

      @velocity = options.velocity ? {horizontal: 0, vertical: 0}

      @createdAt = new Date().getTime()

    update: ->
      @x += @velocity.horizontal
      @y += @velocity.vertical

    contains: ->
      false

  class Ship extends Thing
    constructor: (options = {}) ->
      super(options)

      @angle = options.angle ? 0
      @maxSpeed = options.maxSpeed ? 7

      @thrusters = null

      @wrap = true

    update: ->
      @accelerate() if @thrusters
      super()

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
        @world.addThing new Exhaust {x: @x - 10 * Math.cos(@angle), y: @y - 10 * Math.sin(@angle)}
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

    fire: ->
      @world.addThing new Bullet {x: @x + 10 * Math.cos(@angle), y: @y + 10 * Math.sin(@angle), lifespan: 10000, velocity: {horizontal: 10 * Math.cos(@angle), vertical: 10 * Math.sin(@angle)}}

    collides_with: (thing) ->
      if thing.contains({x: @x, y: @y}) then yes else no

    reset: ->
      @x = 0
      @y = 0
      @angle = 0
      @velocity =
        horizontal: 0
        vertical: 0

  class Exhaust extends Thing
    constructor: (options = {}) ->
      super(options)
      @lifespan = options.lifespan ? 1000

    update: ->
      percentCompleted = (@world.now - @createdAt) / @lifespan
      @alpha = 1 - percentCompleted
      @radius = 1 + 6 * percentCompleted
      @cull = true if @alpha < 0.01

    render: (ctx) ->
      ctx.fillStyle = "rgba(255, 100, 200, #{@alpha})"
      ctx.circle({x: 0, y: 0}, @radius)

  class Bullet extends Thing
    render: (ctx) ->
      ctx.fillStyle = "white"
      ctx.circle({x: 0, y: 0}, 2)

  class Asteroid extends Thing
    constructor: (options = {}) ->
      super(options)
      @radius = options.radius ? 50
      @sides = options.sides ? 5

    render: (ctx) ->
      angle = 0

      ctx.beginPath()
      [x, y] = [@radius * Math.cos(angle), @radius * Math.sin(angle)]
      ctx.moveTo(x, y)

      for side in [1...@sides]
        angle += 2 * Math.PI / @sides
        [x, y] = [@radius * Math.cos(angle), @radius * Math.sin(angle)]
        ctx.lineTo(x, y)

      ctx.closePath()
      ctx.strokeStyle = "rgb(200, 200, 200)"
      ctx.fillStyle = "rgba(200, 200, 200, 0.67)"
      ctx.stroke()
      ctx.fill()

    contains: (point) ->
      Math.sqrt(Math.pow(@x - point.x, 2) + Math.pow(@y - point.y, 2)) <= @radius

  class X extends Thing
    constructor: (options = {}) ->
      super(options)
      @color = options.color ? "white"
      @size = options.size ? 5

    render: (ctx) ->
      ctx.strokeStyle = @color
      ctx.lineWidth = 1

      ctx.line {x: -@size, y: -@size}, {x: @size, y: @size}
      ctx.line {x: -@size, y: @size}, {x: @size, y: -@size}

  canvas = document.getElementsByTagName('canvas')[0]
  canvas.height = window.innerHeight
  canvas.width = window.innerWidth

  world = new World canvas
  ship = new Ship({x: 0, y: 0, maxSpeed: 3})
  world.addThing ship

  asteroid = new Asteroid({x: -200, y: -175})
  world.addThing asteroid

  document.addEventListener 'keydown', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.fireThrusters()
      when 'A' then ship.turnLeft()
      when 'D' then ship.turnRight()
      when 'X' then ship.reset()
      when ' ' then ship.fire()
  ), false

  document.addEventListener 'keyup', ((event) ->
    switch String.fromCharCode event.which
      when 'W' then ship.stopThrusters()
  ), false

  animate -> world.render()
), false
