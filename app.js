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

io.set('log level', 2);

server.listen(PORT);

lobby = {
    // pid : name
    players : {},
    // the pid of the host of the game (first one who joins)
    host : undefined,
    properties : {
        scoreLimit: 2,
    }
}

globalCounter = 0;

io.sockets.on('connection', function (socket) {
    var uniqId = globalCounter++;
    var player = {};
    if(lobby.players.length === 0) {
        lobby.host = uniqId;
    }
    lobby.players[uniqId] = player;

    // this is expected to be called exactly once when the socket joins
    socket.on('join', function (name) {
        console.log(name, "joined");
        player.name = name;
        io.sockets.emit('currentlobby', lobby);
    });

    socket.on('updateProperties', function (properties) {
        lobby.properties = properties;
        io.sockets.emit('currentlobby', lobby)
    })

    socket.on('gamestart', function(gameProperties) {
        io.sockets.emit('gamestart', gameProperties);
    });

    socket.on('disconnect', function() {
        console.log("got disconnect for player", player.name, "with uniqId", uniqId);
        console.log("players are currently", lobby.players);
        delete lobby.players[uniqId];
        io.sockets.emit('currentlobby', lobby);
        io.sockets.emit('playerDisconnected', player.name);
        console.log("players are now", lobby.players);
    });

    socket.on('inputPacket', function(inputSerialized, frameStamp) {
        io.sockets.emit('inputPacket', player.name, inputSerialized, frameStamp);
    })

});

