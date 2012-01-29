class Wall extends Thing
  constructor: (options = {}) ->
    super(options)

    @kill = options.kill
    @segment = new Segment(@, options.end)

  render: (ctx) ->
    ctx.beginPath()
    ctx.moveTo 0, 0
    ctx.lineTo @segment.b.x - @x, @segment.b.y - @y

    ctx.strokeStyle = "blue"
    ctx.lineWidth = 2
    ctx.stroke()

  collides_with: (thing) ->
    switch @kill
      when "top" then thing.y <= @y
      when "bottom" then thing.y >= @y
      when "left" then thing.x <= @x
      when "right" then thing.x >= @x
      else false

  in_viewport: (viewport) ->
    return true if @segment.vertical() and viewport.x <= @x <= viewport.x + viewport.width
    return true if @segment.horizontal() and viewport.y <= @y <= viewport.y + viewport.height
    false
