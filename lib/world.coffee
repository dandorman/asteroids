class World
  constructor: (@canvas) ->
    @ctx = @canvas.getContext '2d'
    @things = []

    @bg = 'black'

  addThing: (thing) ->
    @things.unshift thing
    thing.world = this

  getThing: (id) ->
    for thing in @things
      return thing if thing.id is id

  contains: (thing) ->
    -thing.radius < thing.x < @canvas.width + thing.radius and
      -thing.radius < thing.y < @canvas.height + thing.radius

  drawBackground: ->
    @ctx.fillStyle = @bg
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height

    @ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)'
    for i in [0..Math.max(@canvas.height, @canvas.width)] by 100
      @ctx.line {x: i, y: 0}, {x: i, y: @canvas.height}
      @ctx.line {x: 0, y: i}, {x: @canvas.width, y: i}

  render: ->
    @now = new Date().getTime()

    @drawBackground()

    for thing in @things
      @ctx.save()

      thing.update()
      if thing.wrap
        if thing.x > @canvas.width
          thing.x = 0
        else if thing.x < 0
          thing.x = @canvas.width

        if thing.y > @canvas.height
          thing.y = 0
        else if thing.y < 0
          thing.y = @canvas.height
      else
        thing.reap() unless @contains thing

      @ctx.translate thing.x, thing.y
      thing.render @ctx

      if thing instanceof Ship
        for other in @things
          continue if other is thing
          if thing.collides_with? other
            thing.collided_with? other
            other.collided_with? thing

      @ctx.restore()

    @things = @things.filter (thing) -> not thing.cull

    animate => @render()
