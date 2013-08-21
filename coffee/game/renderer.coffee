define ['b2'], (b2) ->

  class Renderer
    constructor: (@viewportWidth, @cq) ->
      @center = new b2.Vec2() # world coordinates

      # setup debug draw
      @debugDraw = new b2.DebugDraw()
      @debugDraw.SetFlags(b2.DebugDraw.e_shapeBit | b2.DebugDraw.e_jointBit)

    lookAt: (center) => @center.SetV(center)

    # Move the renderer window by the given world offset
    translate: (delta) => @center.Add(delta)

    # convert the given screen location to its corresponding location on the screen
    worldVec2: (screenVec2) =>
      worldVec2 = new b2.Vec2()
      worldVec2.SetV(screenVec2)
      # express the location relative to the center of the canvas
      worldVec2.x -= @cq.canvas.width / 2
      worldVec2.y -= @cq.canvas.height / 2

      worldVec2.Multiply(1 / @scale())
      worldVec2.Add(@center)

      worldVec2

    scale: => @cq.canvas.width / @viewportWidth

    render: (keysPressed, mouse, game) =>
      game.world.SetDebugDraw(@debugDraw)

      @lookAt(game.you.GetPosition())
      @center.SetV(@worldVec2(new b2.Vec2(mouse.x, mouse.y)))

      @debugDraw.SetSprite(@cq.context)
      @debugDraw.SetDrawScale(@scale())
      @debugDraw.SetFillAlpha(0.5)
      @debugDraw.SetLineThickness(0.05)

      @cq.clear()
      @cq.context.save()

      @cq.translate(
        @cq.canvas.width/2 - @center.x * @scale(),
        @cq.canvas.height/2 - @center.y * @scale()
      )

      game.world.DrawDebugData()

      @cq.context.restore()

  return Renderer
