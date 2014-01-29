require [
  'jquery'
  'underscore'
  'socket.io'
  'game/framework'
], ($, _, io, framework) ->
  $("<script src='http://"+window.location.hostname+":35729/livereload.js'></scr" + "ipt>").appendTo("head")

  window.framework = framework

  # AUTOSTART_PLAYERS = 2


  randomName = (String.fromCharCode(65 + Math.random() * 26) for x in [0..8]).join("")
  $("#lobby").append("<h3> Players: </h3><div id='players'></div>")

  $("<button>Start</button>").appendTo("#lobby").on("click", (evt) ->
    socket.emit('start')
  )


  lobby = {
    currentPlayers: []
  }

  socket = io.connect()
  socket.emit('join', randomName)

  # called whenever the lobby gets updated
  socket.on('currentlobby', (currentPlayers) ->
    lobby.currentPlayers = currentPlayers
    $("#players").empty()
    _.each(currentPlayers, (player) ->
      $("#players").append("<p>#{player.name}</p>")
    )

    if !!(AUTOSTART_PLAYERS?) and _.size(currentPlayers) >= AUTOSTART_PLAYERS
      socket.emit('start')
  )
  socket.on('gamestart', () ->
    if !framework.isRunning()
      yourName = randomName
      framework.setup(socket, _.map(lobby.currentPlayers, (p) -> p.name), yourName)
      $("#lobby").hide()
    else
      console.log("got multiple gamestarts!")
  )

  # called when the game has started and a player drops
  socket.on('playerDisconnected', (playerName) ->
    console.log(playerName, "disconnected!")
    framework.onDisconnected(playerName)
  )

  socket.on('inputPacket', (playerName, inputSerialized, frameStamp) ->
    framework.onInputPacket(playerName, inputSerialized, frameStamp)
  )

  socket.on('hashcode', (hash, frame) ->
    framework.onHashcode(hash, frame)
  )

