if ( process.env.NODE_ENV === undefined ) {
    console.log("No NODE_ENV found in environment; assuming development!");
    process.env.NODE_ENV = 'development';
}

var express = require('express')
  , app = express()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server)
  , _ = require('underscore')
  , path = require('path')

var environment = require(path.join(__dirname, 'environments', process.env.NODE_ENV));

PORT = environment.port || 80;

app.configure(function() {
    app.use(express.logger());
    app.use(express.static(path.join(__dirname, 'public')));
    app.use(express.bodyParser());
    app.use(express.static(path.join(__dirname, 'compiled')));
});

app.get(/^\/(\d+)/, function (req, res) {
    res.sendfile("room.html");
});

app.get("/lobby_list.json", function (req, res) {
    res.json({lobbies: lobbies});
});

app.get("/js/settings.js", function (req, res) {
    res.send("var settings = " + JSON.stringify(settings));
});

module.exports = {};

app.post("/settings.json", function (req, res) {
    console.log(req);
    settings = req.body;
    res.send(settings);
    console.log("Got settings ", settings);
    module.exports.req = req;
});

app.get("/new", function (req, res) {
    var firstFreeRoom = 0;
    for( firstFreeRoom = 0; lobbies[firstFreeRoom] !== undefined; firstFreeRoom += 1) {}
    res.redirect("/" + firstFreeRoom)
});

io.set('log level', environment.socket_io_log_level || 2);

server.listen(PORT);

lobbies = {};

settings = {
    block : {
                friction : 1,
                size : 1,
                isStatic : true,
            },

    bullet : {
                 speed : 8,
                 radius : 0.05,
             },

    player : {
                 walkForce : 4,
                 jumpImpulse : -0.37281,
                 width : 0.2,
                 height : 0.6,
                 visionPolyDetail : 100,
             },

    frameOffset : 5,
};

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
    // room is an integer
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

            // delete the room if it's empty
            if(_.size(lobby.players) === 0) {
                delete lobbies[room];
            }
        });

        socket.on('inputPacket', function(inputSerialized, frameStamp) {
            io.sockets.in(room).emit('inputPacket', player.name, inputSerialized, frameStamp);
        })

    });

});

