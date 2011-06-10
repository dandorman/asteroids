animate = do ->
  for fn in ["requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame"]
    return fn if typeof fn is "function"
  (callback) -> setTimeout(callback, 1000 / 60)

distance_between_points = (a, b) ->
  ((a.x - b.x).squared() + (a.y - b.y).squared()).square_root()

within = (a, b, delta = 0.001) ->
  (a - b).abs() <= delta