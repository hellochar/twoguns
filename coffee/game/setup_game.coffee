require ['jquery', 'underscore', 'socket.io', 'game/framework'], ($, _, io, framework) ->

  window.framework = framework

  randomName = (String.fromCharCode(65 + Math.random() * 26) for x in [0..8]).join("")
  $("body").append("<h3> Lobby: </h3><div id='lobby'></div>")

  $("<button>Start</button>").appendTo("body").on("click", (evt) ->
    socket.emit('start')
  )


  lobby = {
    currentPlayers: []
  }

  socket = io.connect('http://localhost')
  socket.emit('join', randomName)

  # called whenever the lobby gets updated
  socket.on('currentlobby', (currentPlayers) ->
    lobby.currentPlayers = currentPlayers
    $("#lobby").empty()
    _.each(currentPlayers, (player) ->
      $("#lobby").append("<p>#{player.name}</p>")
    )
  )
  socket.on('gamestart', () ->
    yourName = randomName
    framework.setup(_.map(lobby.currentPlayers, (p) -> p.name), yourName)
  )

  # called when the game has started and a player drops
  socket.on('playerDisconnected', (name) ->
    console.log(name, "disconnected!")
    framework.onDisconnected(name)
  )

  # $("body").on('onunload', () ->
  #   socket.disconnect()
  #   true
  # )

