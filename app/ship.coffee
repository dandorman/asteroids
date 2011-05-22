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
