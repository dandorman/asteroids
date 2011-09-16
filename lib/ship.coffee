class Ship extends Thing
  constructor: (options = {}) ->
    super(options)

    @color = options.color ? {r: 0, g: 255, b: 0}

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

    ctx.strokeStyle = "rgb(#{@color.r}, #{@color.g}, #{@color.b})"
    ctx.fillStyle = "rgba(#{@color.r}, #{@color.g}, #{@color.b}, 0.67)"
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

    throttler = ->
      @velocity.horizontal += Math.cos @angle
      @velocity.vertical += Math.sin @angle

      if (hypotenuseSquared = Math.pow(@velocity.horizontal, 2) + Math.pow(@velocity.vertical, 2)) > Math.pow(@maxSpeed, 2)
        hypotenuse = Math.sqrt hypotenuseSquared
        @velocity.horizontal = @maxSpeed * @velocity.horizontal / hypotenuse
        @velocity.vertical = @maxSpeed * @velocity.vertical / hypotenuse

      publish 'ship:moved', [@]

      timeout = setTimeout((-> timeout = null), 250)

    ->
      throttler.call @ unless timeout

  turnLeft: ->
    @angle -= Math.PI / 12
    publish 'ship:moved', [@]

  turnRight: ->
    @angle += Math.PI / 12
    publish 'ship:moved', [@]

  fire: do ->
    timeout = null

    throttler = ->
      bullet = new Bullet
        x: @x + 10 * Math.cos(@angle)
        y: @y + 10 * Math.sin(@angle)
        lifespan: 10000,
        velocity:
          horizontal: 10 * Math.cos(@angle)
          vertical: 10 * Math.sin(@angle)
      @world.addThing bullet
      publish 'ship:fired', [@, bullet]

      timeout = setTimeout((-> timeout = null), 1000)

    ->
      throttler.call @ unless timeout

  explode: ->
    @cull = true
    @world.addThing new Explosion x: @x, y: @y

  collides_with: (thing) ->
    if thing instanceof Bullet
      distance_between_points(@position(), thing.position()) < 10
    else
      thing.contains? x: @x, y: @y

  collided_with: (thing) ->
    @explode()

  reset: ->
    @x = 0
    @y = 0
    @angle = 0
    @velocity =
      horizontal: 0
      vertical: 0
