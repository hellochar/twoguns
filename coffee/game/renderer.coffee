define ['b2'], (b2) ->

  class Renderer
    constructor: (@viewportWidth) ->
      @center = new b2.Vec2() # world coordinates

      # setup debug draw
      @debugDraw = new b2.DebugDraw()
      @debugDraw.SetFlags(b2.DebugDraw.e_shapeBit | b2.DebugDraw.e_jointBit)

    lookAt: (center) =>
      @center.SetV(center)

    translate: (delta) => @center.Add(delta)


    render: (cq, keysPressed, mouse, game) =>
      game.world.SetDebugDraw(@debugDraw)

      scale = cq.canvas.width / @viewportWidth

      #
      # ===========translateScreen===========
      # Move the camera by the given screen coordinate offset
      #
      # must be defined inside the render method because only inside render do we have a cq
      #
      translateScreen = (delta) =>
          delta.Multiply(1 / scale)
          @center.Add(delta)

      @lookAt(game.you.GetPosition())
      translateScreen(new b2.Vec2(mouse.x - cq.canvas.width/2, mouse.y - cq.canvas.height/2))

      @debugDraw.SetSprite(cq.context)
      @debugDraw.SetDrawScale(scale)
      @debugDraw.SetFillAlpha(0.5)
      @debugDraw.SetLineThickness(0.05)

      cq.clear()
      cq.context.save()

      cq.translate(
        cq.canvas.width/2 - @center.x * scale,
        cq.canvas.height/2 - @center.y * scale
      )

      game.world.DrawDebugData()

      cq.context.restore()

  return Renderer
