class Explosion extends Thing
  constructor: (options = {}) ->
    super(options)

    @maxRadius = options.radius ? 100
    @duration = options.duration ? 500
    @color = options.color ? {r: 255, g: 64, b: 0}

  update: ->
    super()

    elapsed = +(new Date()) - @createdAt

    @radius = @maxRadius * elapsed / @duration
    @opacity = 1.0 - elapsed / @duration

    @cull = true if elapsed > @duration

  render: (ctx) ->
    ctx.fillStyle = "rgba(#{@color.r}, #{@color.g}, #{@color.b}, #{@opacity})"
    ctx.circle({x: 0, y: 0}, @radius)
