require ['jquery', 'b2', 'socket.io', 'canvasquery', 'game/game', 'game/renderer'], ($, b2, io, cq, Game, Renderer) ->

  socket = io.connect('http://localhost')
  socket.on('news', (data) ->
    console.log(data)
    socket.emit('my other event', { my: 'data' })
  )

  keysPressed = {} # key1: true, key2: true, key3: true
  mouse = {
    x : 0,
    y : 0, # pixel coordinates of mouse relative to top-left of canvas
    button : -1, # -1,0,1,2 === not-pressed, left, middle, right
  }

  # The framework hooks the renderer and game model together, and also handles events
  # Events make the core of the framework. You can think of the game as just being a bunch of events happening, and responding accordingly
  framework = {

    setup : () ->
      @cq = cq().framework(this, this)
      @cq.appendTo("body")
      mouse.x = @cq.canvas.width/2
      mouse.y = @cq.canvas.height/2
      @game = new Game(80, 20, 1)
      @renderer = new Renderer(20, @cq)

      @stats = new Stats()
      @stats.setMode(0)

      @stats.domElement.style.position = 'absolute'
      @stats.domElement.style.left = '0px'
      @stats.domElement.style.top = '0px'

      document.body.appendChild( @stats.domElement )

    # game logic loop
    onStep: (delta, time) ->
      @stats.begin()
      @game.step(keysPressed, mouse, delta)
      @stats.end()

    # rendering loop
    onRender: (delta, time) ->
      @renderer.render(keysPressed, mouse, @game)

    # window resize
    onResize: (width, height) ->
      # resize canvas with window
      # change camera transform
      if @cq
        @cq.canvas.height = height
        @cq.canvas.width = width

    # mouse and touch events
    onMouseDown: (x, y, button) ->
      mouse.button = button
      mouse.x = x
      mouse.y = y
      @game.mouseDown(@renderer.worldVec2(new b2.Vec2(x, y)), button)
    onMouseUp: (x, y, button) ->
      mouse.button = -1
      mouse.x = x
      mouse.y = y
    onMouseMove: (x, y) ->
      mouse.x = x
      mouse.y = y

    # keyboard events
    onKeyDown: (key) ->
      keysPressed[key] = true
    onKeyUp: (key) ->
      delete keysPressed[key]
  }

  framework.setup()
