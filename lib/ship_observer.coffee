class ShipObserver
  constructor: (@socket) ->
    subscribe 'ship:moved', (ship) => @moved ship
    subscribe 'ship:fired', (ship, bullet) => @fired ship, bullet
    subscribe 'ship:exploded', (ship) => @exploded ship

  moved: (ship) ->
    data =
      id: ship.id
      position: ship.position()
      angle: ship.angle
      velocity: ship.velocity
    @socket.emit('update', data)

  fired: (ship, bullet) ->
    data =
      position: bullet.position()
      velocity: bullet.velocity
    @socket.emit('ship:fired', data)

  exploded: (ship) ->
    @socket.emit('ship:exploded', id: ship.id)
