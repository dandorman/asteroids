class World
  constructor: (@canvas) ->
    @ctx = @canvas.getContext '2d'
    @things = []

    @bg = 'black'

    @quadrant =
      width: @canvas.width / 2
      height: @canvas.height / 2

    @ctx.translate @quadrant.width, @quadrant.height

  addThing: (thing) ->
    @things.unshift thing
    thing.world = this

  contains: (thing) ->
    @quadrant.width > thing.x > -@quadrant.width and @quadrant.height > thing.y > -@quadrant.height

  drawBackground: ->
    @ctx.fillStyle = @bg
    @ctx.fillRect -@quadrant.width, -@quadrant.height, @canvas.width, @canvas.height

    @ctx.strokeStyle = 'rgba(128, 128, 255, 0.5)'
    for i in [0..Math.max(@quadrant.height, @quadrant.width)] by 100
      @ctx.line {x: i, y: -@quadrant.height}, {x: i, y: @quadrant.height}
      @ctx.line {x: -@quadrant.width, y: i}, {x: @quadrant.width, y: i}

      if i
        @ctx.line {x: -i, y: -@quadrant.height}, {x: -i, y: @quadrant.height}
        @ctx.line {x: -@quadrant.width, y: -i}, {x: @quadrant.width, y: -i}

  render: ->
    @now = new Date().getTime()

    @drawBackground()

    for thing in @things
      @ctx.save()

      thing.update()
      if thing.wrap
        thing.x = @quadrant.width * -thing.x.sign() unless @quadrant.width > thing.x > -@quadrant.width
        thing.y = @quadrant.height * -thing.y.sign() unless @quadrant.height > thing.y > -@quadrant.height
      else
        thing.cull = true unless @contains thing

      @ctx.translate thing.x, thing.y
      thing.render @ctx

      for other in @things
        break if other is thing
        if thing.collides_with? other
          thing.collided_with? other
          other.collided_with? thing

      @ctx.restore()

    @things = @things.filter (thing) -> not thing.cull

    animate => @render()
