define [ 'b2', 'canvasquery', 'game/game', 'game/player', 'game/renderer'], (b2, cq, Game, Player, Renderer) ->

  keysPressed = {} # key1: true, key2: true, key3: true
  mouse = {
    x : 0,
    y : 0, # pixel coordinates of mouse relative to top-left of canvas
    button : -1, # -1,0,1,2 === not-pressed, left, middle, right
  }

  # The framework hooks the renderer and game model together, and also handles events
  # Events make the core of the framework. You can think of the game as just being a bunch of events happening, and responding accordingly
  framework = {

    setup : (yourName) ->
      @cq = cq().framework(this, this)
      @cq.appendTo("body")
      mouse.x = @cq.canvas.width/2
      mouse.y = @cq.canvas.height/2
      @game = new Game(80, 20, new Player(yourName))
      @renderer = new Renderer(18, @game, @cq)

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
      mouseWorld = {
        location: @renderer.worldVec2(new b2.Vec2(mouse.x, mouse.y))
        button: mouse.button
      }
      @game.step(keysPressed, mouseWorld, delta)
      @statsStep.end()

    # rendering loop
    onRender: (delta, time) ->
      @statsRender.begin()
      @renderer.render(keysPressed, mouse, @game)
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

  return framework
