class Thing
  constructor: (options = {}) ->
    @x = options.x
    @y = options.y

    @velocity = options.velocity ? {horizontal: 0, vertical: 0}

    @createdAt = new Date().getTime()

  update: ->
    @x += @velocity.horizontal
    @y += @velocity.vertical
