doctype 5
html ->
  head ->
    title 'Asteroids'
    style '''
      html, body { margin: 0; padding: 0; height: 100%; width: 100% }
    '''
    script src: "/socket.io/socket.io.js"
    script src: "/minpubsub.js"
    script src: "/asteroids.js"
  body ->
    canvas height: 750, width: 750
