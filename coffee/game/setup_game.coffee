require [
  'jquery'
  'underscore'
  'socket.io'
  'lobby'
  'game/framework'
], ($, _, io, Lobby, framework) ->
  $("<script src='http://"+window.location.hostname+":35729/livereload.js'></scr" + "ipt>").appendTo("head")

  window.framework = framework

  # AUTOSTART_PLAYERS = 1
  

  randomName = () ->
    (String.fromCharCode(65 + Math.random() * 26) for x in [0..8]).join("")

  socket = io.connect()
  lobby = new Lobby(socket, randomName())
  lobby.join()

  # # called whenever the lobby gets updated
  # socket.on('currentlobby', (lobbyState) ->
  #   lobby = lobbyState
  #   # if !!(AUTOSTART_PLAYERS?) and _.size(currentPlayers) >= AUTOSTART_PLAYERS
  #   #   socket.emit('start')
  # )

  socket.on('gamestart', (gameProperties) ->
    if !framework.isRunning()
      # hack on players to the game properties
      gameProperties.playerNames = (p.name for idx, p of lobby.players)
      gameProperties.yourName = lobby.yourName
      framework.setup(socket, gameProperties)
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

