class World
  constructor: (@canvas) ->
    @ctx = @canvas.getContext '2d'
    @things = []

    @width = 1500
    @height = 1500

    @things.push new Wall(x: 10, y: 10, end: { x: @width - 10, y: 10 }, kill: "top")
    @things.push new Wall(x: 10, y: @height - 10, end: { x: @width - 10, y: @height - 10 }, kill: "bottom")
    @things.push new Wall(x: 10, y: 10, end: { x: 10, y: @height - 10 }, kill: "left")
    @things.push new Wall(x: @width - 10, y: 10, end: { x: @width - 10, y: @height - 10 }, kill: "right")

    @viewport =
      x: 0
      y: 0
      width: @canvas.width
      height: @canvas.height

    @bg = 'black'

  addThing: (thing) ->
    @things.unshift thing
    thing.world = this

  getThing: (id) ->
    for thing in @things
      return thing if thing.id is id

  contains: (thing) ->
    -thing.radius < thing.x < @width + thing.radius and
      -thing.radius < thing.y < @height + thing.radius

  drawBackground: ->
    @ctx.fillStyle = @bg
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height

    # @ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)'
    # for i in [0..Math.max(@canvas.height, @canvas.width)] by 100
    #   @ctx.line {x: i, y: 0}, {x: i, y: @canvas.height}
    #   @ctx.line {x: 0, y: i}, {x: @canvas.width, y: i}

  render: ->
    @now = new Date().getTime()

    @drawBackground()

    for thing in @things
      @ctx.save()

      thing.update()
      thing.reap() unless @contains thing

      @ctx.translate thing.x - @viewport.x, thing.y - @viewport.y
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

  center_viewport_at: (x, y) ->
    @viewport.x = Math.max(0, Math.min(x - @viewport.width / 2, @width - @viewport.width))
    @viewport.y = Math.max(0, Math.min(y - @viewport.height / 2, @height - @viewport.height))
