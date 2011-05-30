class Line
  constructor: (@a, @b) ->

  # http://en.wikipedia.org/wiki/Line-line_intersection
  intersection: (line) ->
    return undefined if @parallel_to(line)
    x: ((@a.x * @b.y - @a.y * @b.x) * (line.a.x - line.b.x) - (@a.x - @b.x) * (line.a.x * line.b.y - line.a.y * line.b.x)) / ((@a.x - @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x - line.b.x))
    y: ((@a.x * @b.y - @a.y * @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x * line.b.y - line.a.y * line.b.x)) / ((@a.x - @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x - line.b.x))

  slope: ->
    @slope ?= (@b.y - @a.y) / (@b.x - @a.x)

  parallel_to: (line) ->
    Math.abs(@slope() - line.slope()) < 0.001
