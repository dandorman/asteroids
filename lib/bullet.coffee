class Bullet extends Thing
  render: (ctx) ->
    ctx.fillStyle = "white"
    ctx.circle({x: 0, y: 0}, 2)

  collides_with: (thing) ->
    thing.contains? x: @x, y: @y

  collided_with: (thing) ->
    @cull = true
