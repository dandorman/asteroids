class Bullet extends Thing
  render: (ctx) ->
    ctx.fillStyle = "white"
    ctx.circle({x: 0, y: 0}, 2)
