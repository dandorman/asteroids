class ShipObserver
  constructor: (@socket) ->
    subscribe 'ship:moved', (ship) => @moved ship
    subscribe 'ship:fired', (ship, bullet) => @fired ship, bullet
    subscribe 'ship:exploded', (ship) => @exploded ship

  moved: (ship) ->
    data =
      id: ship.id
      p: ship.position()
      a: ship.angle
      v:
        h: ship.velocity.horizontal
        v: ship.velocity.vertical
    @socket.emit 'update', data

  fired: (ship, bullet) ->
    data =
      p: bullet.position()
      v:
        h: bullet.velocity.horizontal
        v: bullet.velocity.vertical
    @socket.emit 'ship:fired', data

  exploded: (ship) ->
    @socket.emit 'ship:exploded', id: ship.id
