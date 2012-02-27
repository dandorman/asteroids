doctype 5
html ->
  head ->
    title 'Disasteroids'
    style '''
      * { box-sizing: border-box }

      html, body {
        font-family: Helvetica, sans-serif;
        margin: 0;
        padding: 0;
        height: 100%;
        width: 100%
      }

      .container { margin: 0 auto; width: 960px }
      .main { float: left; width: 750px }
      .info { float: left; margin-left: 10px; width: 200px }
    '''
    script src: "/socket.io/socket.io.js"
    script src: "/ender.min.js"
    script src: "/asteroids.js"
  body ->
    div ".container", ->
      h1 "Disasteroids"
      div ->
        div ".main", ->
          canvas height: 750, width: 750
        div ".info", ->
          div ".connection-status", style: "display: none", "Disconnected"
          form ".register", ->
            div ->
              input name: "name", placeholder: "name"
            div ->
              input ".color", name: "red", maxlength: 3, size: 3, placeholder: "r"
              input ".color", name: "green", maxlength: 3, size: 3, placeholder: "g"
              input ".color", name: "blue", maxlength: 3, size: 3, placeholder: "b"
            div ->
              button "Join"
          div ".color", ""
