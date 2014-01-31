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


app.get(/^\/(\d+)/, function (req, res) {
    res.sendfile("room.html")
});

app.get('/', function (req, res) {
    res.send("type in a room id")
});

app.get("/lobby_list.json", function (req, res) {
    res.json({lobbies: lobbies})
});

io.set('log level', 3);

server.listen(PORT);

lobbies = {}

function newLobby() {
    return {
        // pid : name
        players : {},
        // the pid of the host of the game (first one who joins)
        host : undefined,
        properties : {
            scoreLimit: 2,
            mapWidth: 20,
            mapHeight: 10,
            randomSeed: 0,
        }
    }
}

function getLobby(roomName) {
    lobbies[roomName] = lobbies[roomName] || newLobby();
    return lobbies[roomName];
}


globalCounter = 0;

io.sockets.on('connection', function (socket) {
    // this is expected to be called exactly once when the socket joins
    socket.on('join', function (room, name) {
        var lobby = getLobby(room);

        var uniqId = globalCounter++;
        var player = {};
        if(lobby.players.length === 0) {
            lobby.host = uniqId;
        }
        lobby.players[uniqId] = player;

        player.name = name;

        socket.join(room);

        console.log(name, "joined room", room);

        io.sockets.in(room).emit('currentlobby', lobby);

        socket.on('updateProperties', function (properties) {
            lobby.properties = properties;
            io.sockets.in(room).emit('currentlobby', lobby)
        })

        socket.on('gamestart', function(gameProperties) {
            io.sockets.in(room).emit('gamestart', gameProperties);
        });

        socket.on('disconnect', function() {
            console.log("got disconnect for player", player.name, "with uniqId", uniqId);
            console.log("players are currently", lobby.players);
            delete lobby.players[uniqId];
            io.sockets.in(room).emit('currentlobby', lobby);
            io.sockets.in(room).emit('playerDisconnected', player.name);
            console.log("players are now", lobby.players);
        });

        socket.on('inputPacket', function(inputSerialized, frameStamp) {
            io.sockets.in(room).emit('inputPacket', player.name, inputSerialized, frameStamp);
        })

    });

});

