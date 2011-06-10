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
