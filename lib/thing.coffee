class Thing
  constructor: (options = {}) ->
    @id = options.id ? 0

    @x = options.x ? 0
    @y = options.y ? 0

    @velocity = options.velocity ? {horizontal: 0, vertical: 0}

    @createdAt = new Date().getTime()

  update: ->
    @x += @velocity.horizontal
    @y += @velocity.vertical

  position: ->
    x: @x
    y: @y
