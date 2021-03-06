define [
  'underscore'
  'b2'
  'canvasquery'
  'overlay'
  'settings'
  'game/game'
  'game/inputs'
  'game/random'
  'game/input_network_collector'
  'game/render/renderer'
], (_, b2, cq, Overlay, settings, Game, Inputs, Random, InputNetworkCollector, Renderer) ->

  framework = {
    isRunning: () -> !!@hasSetup

    setup : (socket, gameProperties) ->
      throw new Error("framework.setup() called more than once!") if @isRunning()
      @hasSetup = true
      @socket = socket
      @gameProperties = gameProperties
      @cq = cq().framework(this, this)
      @cq.canvas.oncontextmenu = () -> false
      @cq.appendTo("body")
      @input = new Inputs(
        {x: @cq.canvas.width/2, y: @cq.canvas.height/2},
        {}
      )
      @game = new Game(gameProperties.mapWidth, gameProperties.mapHeight, gameProperties.playerNames, gameProperties.yourName, new Random(gameProperties.randomSeed))
      window.you = @game.youPlayer
      @renderer = new Renderer(18, @game, @cq)
      @networkCollector = new InputNetworkCollector(@game, @socket, settings.frameOffset)

      # track calls to rayintersect and output it
      ( =>
        invocations = 0
        indicator = $("<div/>").appendTo("#debughud")
        $(@game).on('rayintersectall', () ->
          invocations += 1
        )
        $(@renderer).on('rendered', () ->
          indicator.text("#{invocations} ray intersections!")
          invocations = 0
        )
      )()

      ( =>
        latencydiv = $("<div>").appendTo("#debughud")
        $(@game).on('poststep', () =>
          latencydiv.text("#{Math.floor(@networkCollector.getLatency())} ms ping")
        )
      )()

      @statsStep = new Stats()
      @statsStep.setMode(0)
      @statsStep.domElement.style.left = '0px'
      @statsStep.domElement.style.top = '0px'

      @statsRender = new Stats()
      @statsRender.setMode(0)
      @statsRender.domElement.style.left = '0px'
      @statsRender.domElement.style.top = '50px'

      $("#debughud").append( @statsStep.domElement )
      $("#debughud").append( @statsRender.domElement )

    # game logic loop
    onStep: (delta, time) ->
      @renderer.viewportWidth *= 1.05 if @input.pressed('dash')
      @renderer.viewportWidth /= 1.05 if @input.pressed('equal')

      if @networkCollector.isReady() and not @game.finished
        @statsStep.begin()

        playerInput = @input.toWorld(@renderer)
        @networkCollector.advance(playerInput)

        @game.step()
        @checkWinCondition()
        #hack; should be part of a feature to collect all events that have happened since last step
        @input.mouse.down = false
        @statsStep.end()


    checkWinCondition: () ->
      winningPlayer = _.findWhere(@game.players, {score: @gameProperties.scoreLimit})
      return if not winningPlayer

      @game.finished = true
      if winningPlayer is @game.youPlayer
        Overlay.show("You win!!!")
      else
        Overlay.show("#{winningPlayer.name} won!")
      @socket.disconnect()


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
      if @networkCollector
        @networkCollector.removePlayer(playerName)

    onInputPacket: (playerName, inputSerialized, frameStamp) ->
      @networkCollector.put(playerName, Inputs.unserialize(inputSerialized), frameStamp)

    onHashcode: (hash, frame) ->
      @networkCollector.checkHash(hash, frame)

  }

  return framework
