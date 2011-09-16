class ShipObserver
  constructor: (@socket) ->
    subscribe "ship:moved", (ship) => @moved ship

  moved: (ship) ->
    data =
      id: ship.id
      position: ship.position()
      angle: ship.angle
      velocity: ship.velocity
    @socket.emit('update', data)
