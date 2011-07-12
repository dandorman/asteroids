class Explosion extends Thing
  constructor: (options = {}) ->
    super(options)

    @maxRadius = options.radius ? 100
    @duration = options.duration ? 500

  update: ->
    super()

    elapsed = +(new Date()) - @createdAt

    @radius = @maxRadius * elapsed / @duration
    @opacity = 1.0 - elapsed / @duration

    @cull = true if elapsed > @duration

  render: (ctx) ->
    ctx.fillStyle = "rgba(255, 64, 0, #{@opacity})"
    ctx.circle({x: 0, y: 0}, @radius)
