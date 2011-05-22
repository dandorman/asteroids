(function() {
  var app, express, port;
  express = require('express');
  app = express.createServer();
  app.register('.coffee', require('coffeekup'));
  app.set('view options', {
    layout: false
  });
  app.set('view engine', 'coffee');
  app.configure(function() {
    return app.use(express.static("" + __dirname + "/public"));
  });
  port = 80;
  app.configure('development', function() {
    return port = 3000;
  });
  app.get('/', function(req, res) {
    return res.render('index.coffee');
  });
  app.listen(port);
}).call(this);
