CanvasRenderingContext2D::line = (from, to, options = {}) ->
  @beginPath()
  @moveTo from.x, from.y
  @lineTo to.x, to.y
  @closePath()
  @stroke()

CanvasRenderingContext2D::circle = (at, radius, options = {}) ->
  @beginPath()
  @arc(at.x, at.y, radius, 0, 2 * Math.PI, false)
  @fill()
