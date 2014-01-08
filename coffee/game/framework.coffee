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

  # The framework hooks the renderer and game model together, and also handles events
  # Events make the core of the framework. You can think of the game as just being a bunch of events happening, and responding accordingly
  framework = {
    setup : (socket, playerNames, yourName) ->
      @cq = cq().framework(this, this)
      @cq.appendTo("body")
      @input = new Inputs(
        {x: @cq.canvas.width/2, y: @cq.canvas.height/2},
        {}
      )
      @game = new Game(80, 20, playerNames, yourName)
      @renderer = new Renderer(18, @game, @cq)

      @socket = socket
      @networkCollector = new InputNetworkCollector(@game.players)
      @frame = 0

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
      @statsStep.begin()

      playerInputs = @input.clone()

      # it's a hack to put input logic copying here and will be replaced once network code gets here
      playerInputs.mouse.location = @renderer.worldVec2(new b2.Vec2(@input.mouse.x, @input.mouse.y))
      delete playerInputs.mouse.x
      delete playerInputs.mouse.y

      # @game.youPlayer.inputs = playerInputs
      @socket.emit('inputPacket', playerInputs.serialize(), @frame)

      if @networkCollector.isReady(@frame)
        @networkCollector.loadFrame(@frame)
        @game.step(delta)
        @frame += 1
        @input.mouse.down = false

        console.log("frame #{@frame}, stepped with", @networkCollector.inputGroups[@frame-1], ", hashCode #{@game.hashCode()}")

      @statsStep.end()

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

  }

  return framework
