define [
  'underscore'
  'b2'
  'canvasquery'
  'game/game'
  'game/inputs'
  'game/input_network_collector'
  'game/player'
  'game/render/renderer'
], (_, b2, cq, Game, Inputs, InputNetworkCollector, Player, Renderer) ->

  # induces feedback latency equal to FRAME_OFFSET * (ms per frame)
  FRAME_OFFSET = 2

  framework = {
    setup : (socket, playerNames, yourName) ->
      @cq = cq().framework(this, this)
      @cq.appendTo("body")
      @input = new Inputs(
        {x: @cq.canvas.width/2, y: @cq.canvas.height/2},
        {}
      )
      @game = new Game(30, 80, playerNames, yourName)
      @renderer = new Renderer(18, @game, @cq)

      @socket = socket
      @networkCollector = new InputNetworkCollector(@game.players)
      # start off by filling in the first FRAME_OFFSET inputs with no-ops
      for frame in [0...FRAME_OFFSET]
        for player in @game.players
          @networkCollector.put(player.name, (new Inputs()).toWorld(@renderer), frame)

      @statsStep = new Stats()
      @statsStep.setMode(0)
      @statsStep.domElement.style.position = 'absolute'
      @statsStep.domElement.style.left = '0px'
      @statsStep.domElement.style.top = '0px'

      @statsRender = new Stats()
      @statsRender.setMode(0)
      @statsRender.domElement.style.position = 'absolute'
      @statsRender.domElement.style.left = '0px'
      @statsRender.domElement.style.top = '50px'

      document.body.appendChild( @statsStep.domElement )
      document.body.appendChild( @statsRender.domElement )

    # game logic loop
    onStep: (delta, time) ->
      @renderer.viewportWidth *= 1.05 if @input.pressed('dash')
      @renderer.viewportWidth /= 1.05 if @input.pressed('equal')

      if @networkCollector.isReady()
        @statsStep.begin()

        playerInputs = @input.toWorld(@renderer)
        @socket.emit('inputPacket', playerInputs.serialize(), @networkCollector.frame + FRAME_OFFSET)

        @socket.emit('hashcode', @game.hashCode(), @networkCollector.frame)
        @networkCollector.putHash(@game.hashCode())

        @networkCollector.loadFrame()
        @game.step()
        #hack; should be part of a feature to collect all events that have happened since last step
        @input.mouse.down = false
        @networkCollector.frame += 1
        @statsStep.end()

        # console.log("frame #{@frame}, stepped with", @networkCollector.inputGroups[@frame-1], ", hashCode #{@game.hashCode()}")

    # rendering loop
    onRender: (delta, time) ->
      @statsRender.begin()
      @renderer.render(@input.mouse.x, @input.mouse.y)
      @statsRender.end()


    # window resize
    onResize: (width, height) ->
      # resize canvas with window
      # change camera transform
      if @cq
        @cq.canvas.height = height
        @cq.canvas.width = width

    # mouse and touch events
    onMouseDown: (x, y, button) ->
      @input.mousedown(x, y, button)
    onMouseUp: (x, y, button) ->
      @input.mouseup(x, y, button)
    onMouseMove: (x, y) ->
      @input.setLocation(x, y)

    # keyboard events
    onKeyDown: (key) ->
      @input.keys[key] = true
    onKeyUp: (key) ->
      delete @input.keys[key]

    onDisconnected: (playerName) ->
      # delete player from game
      # - or -
      # keep a list of players "connected"; disconnected players don't need input for the game to continue
      #   also account for reconnect

    onInputPacket: (playerName, inputSerialized, frameStamp) ->
      @networkCollector.put(playerName, Inputs.unserialize(inputSerialized), frameStamp)

    onHashcode: (hash, frame) ->
      @networkCollector.checkHash(hash, frame)

  }

  return framework
