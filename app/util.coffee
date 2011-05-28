animate = do ->
  for fn in ["requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame"]
    return fn if typeof fn is "function"
  (callback) -> setTimeout(callback, 1000 / 60)
