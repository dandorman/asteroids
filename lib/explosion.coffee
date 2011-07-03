class Explosion extends Thing
  update: ->
    super()
    @opacity ?= 1.0
    @opacity *= 0.9

    @radius ?= 10
    @radius *= 1.1

    @cull = true if @radius > 100

  render: (ctx) ->
    ctx.fillStyle = "rgba(255, 64, 0, #{@opacity})"
    ctx.circle({x: 0, y: 0}, @radius)
