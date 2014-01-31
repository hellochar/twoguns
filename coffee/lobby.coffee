define [
], () ->
  # Client view of a Lobby; the server is the authority on this and will send
  # updates/overwrites of what the lobby should look like
  #
  # A lobby has:
  #   list of players
  #   your name
  #   socket to listen to app updates
  #   game properties
  #   a host id
  #
  class Lobby
    constructor: (@socket, @yourName) ->
      @el = $("#lobby")

      @constructHTML()

      @update({
        players: []
        properties: {}
        hostId: undefined
      })

    join: () =>
      @socket.emit('join', @yourName)
      @socket.on('currentlobby', (state) =>
        @update(state)
      )

    constructHTML: () =>
      self = this
      @el.append("<h3> Players: </h3>")
      @el.players = $("<div id='players'></div>").appendTo(@el)
      @el.startButton = $("<button>Start</button>").appendTo(@el).on("click", (evt) =>
        @socket.emit('gamestart', @properties)
      )
      @el.propertiesDiv = $("<div/>").appendTo("#lobby")

      createNumericControl = (name, displayName, min, max) =>
        @el.append(displayName)
        @el[name] = $("<input>").attr(
          type: "number"
          min: min
          max: max
        ).appendTo(@el).change("input", (evt) ->
          self.properties[name] = parseInt($(@).val(), 10)
          self.sendUpdate()
        )

      createNumericControl("scoreLimit", "Score Limit", 1, 1000)

      createNumericControl("mapWidth", "Map Width", 10, 100)
      createNumericControl("mapHeight", "Map Height", 10, 100)

      createNumericControl("randomSeed", "Seed Number", -Infinity, Infinity)

      @el.hostControlNames = ["startButton", "scoreLimit", "mapWidth", "mapHeight", "randomSeed"]

    sendUpdate: () =>
      @socket.emit('updateProperties', @properties)

    update: (state) =>
      @players = state.players
      @properties = state.properties
      @hostId = state.host
      @updateHTML()

    isHost: () =>
      (!!@hostId) and @players[@hostId].name is @yourName

    updateHTML: () =>
      # update properties elements
      @el.scoreLimit.val(@properties.scoreLimit)
      for name in @el.hostControlNames
        @el[name].val(@properties[name]) if @properties[name]

      @el.players.empty()
      for idx, player of @players
        @el.players.append("<p>#{player.name}</p>")

      # update editable powers
      for name in @el.hostControlNames
        @el[name].prop("disabled", @isHost())
