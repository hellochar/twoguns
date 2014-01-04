var express = require('express')
  , app = express()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server)

PORT = 3000;

app.configure(function() {
    app.use(express.static(__dirname + '/public'));
    app.use(express.static(__dirname + '/compiled'));
});

io.set('log level', 2);

server.listen(PORT);

io.sockets.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});
