class Bullet extends Thing
  render: (ctx) ->
    ctx.fillStyle = "white"
    ctx.circle({x: 0, y: 0}, 2)

  collides_with: (thing) ->
    thing.contains? x: @x, y: @y

  collided_with: (thing) ->
    if thing instanceof Asteroid and not @cull
      @world.addThing new Explosion
        x: @x, y: @y,
        duration: 250,
        radius: 20,
        color: {r: 255, g: 239, b: 0}

    @cull = true
