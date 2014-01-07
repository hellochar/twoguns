var express = require('express')
  , app = express()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server)
  , _ = require('underscore')

PORT = 3000;

app.configure(function() {
    app.use(express.static(__dirname + '/public'));
    app.use(express.static(__dirname + '/compiled'));
});

io.set('log level', 3);

server.listen(PORT);

// array of names
currentPlayers = {};
globalCounter = 0;

io.sockets.on('connection', function (socket) {
    var uniqId = globalCounter++;
    var player = {};
    currentPlayers[uniqId] = player;

    // this is expected to be called exactly once when the socket joins
    socket.on('join', function (name) {
        console.log(name, "joined");
        player.name = name;
        io.sockets.emit('currentlobby', currentPlayers);
    });

    socket.on('start', function() {
        io.sockets.emit('gamestart');
    });

    socket.on('disconnect', function() {
        console.log("got disconnect for player", player.name, "with uniqId", uniqId);
        console.log("players are currently", currentPlayers);
        delete currentPlayers[uniqId];
        io.sockets.emit('currentlobby', currentPlayers);
        io.sockets.emit('playerDisconnected', player.name);
        console.log("players are now", currentPlayers);
    });

    socket.on('inputPacket', function(player, time) {
    })

});

