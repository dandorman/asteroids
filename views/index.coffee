doctype 5
html ->
  head ->
    title 'Asteroids'
    style '''
      html, body { margin: 0; padding: 0; height: 100%; width: 100% }
    '''
    script src: "/asteroids.js"
  body ->
    canvas ->
