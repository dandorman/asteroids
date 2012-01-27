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

  point_on_wall: (point) ->
    switch @kill
      when "top" then point.y <= @y
      when "bottom" then point.y >= @y
      when "left" then point.x <= @x
      when "right" then point.x >= @x
      else false

