(function() {
  require(['jquery', 'underscore', 'socket.io', 'lobby', 'game/framework'], function($, _, io, Lobby, framework) {
    var lobby, randomName, socket;
    $("<script src='http://" + window.location.hostname + ":35729/livereload.js'></scr" + "ipt>").appendTo("head");
    window.framework = framework;
    randomName = function() {
      var x;
      return ((function() {
        var _i, _results;
        _results = [];
        for (x = _i = 0; _i <= 8; x = ++_i) {
          _results.push(String.fromCharCode(65 + Math.random() * 26));
        }
        return _results;
      })()).join("");
    };
    socket = io.connect();
    lobby = new Lobby(socket, randomName());
    lobby.join();
    socket.on('gamestart', function(gameProperties) {
      var idx, p;
      if (!framework.isRunning()) {
        gameProperties.playerNames = (function() {
          var _ref, _results;
          _ref = lobby.players;
          _results = [];
          for (idx in _ref) {
            p = _ref[idx];
            _results.push(p.name);
          }
          return _results;
        })();
        gameProperties.yourName = lobby.yourName;
        framework.setup(socket, gameProperties);
        return $("#lobby").hide();
      } else {
        return console.log("got multiple gamestarts!");
      }
    });
    socket.on('playerDisconnected', function(playerName) {
      console.log(playerName, "disconnected!");
      return framework.onDisconnected(playerName);
    });
    socket.on('inputPacket', function(playerName, inputSerialized, frameStamp) {
      return framework.onInputPacket(playerName, inputSerialized, frameStamp);
    });
    return socket.on('hashcode', function(hash, frame) {
      return framework.onHashcode(hash, frame);
    });
  });

}).call(this);
