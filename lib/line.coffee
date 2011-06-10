class Line
  constructor: (@a, @b) ->

  # http://en.wikipedia.org/wiki/Line-line_intersection
  intersection: (line) ->
    return undefined if @parallel_to(line)

    cross_product_a = @a.x * @b.y - @a.y * @b.x
    cross_product_b = line.a.x * line.b.y - line.a.y * line.b.x
    denominator = (@a.x - @b.x) * (line.a.y - line.b.y) - (@a.y - @b.y) * (line.a.x - line.b.x)

    x: (cross_product_a * (line.a.x - line.b.x) - (@a.x - @b.x) * cross_product_b) / denominator
    y: (cross_product_a * (line.a.y - line.b.y) - (@a.y - @b.y) * cross_product_b) / denominator

  slope: ->
    @slope ?= (@b.y - @a.y) / (@b.x - @a.x)

  parallel_to: (line) ->
    Math.abs(@slope() - line.slope()) < 0.001

  horizontal: ->
    Math.abs(@a.y - @b.y) < 0.001

  vertical: ->
    Math.abs(@a.x - @b.x) < 0.001
