define ['b2', 'utils'], (b2, Utils) ->

  class Renderer
    constructor: (@viewportWidth, @game, @cq) ->
      @center = new b2.Vec2() # world coordinates

      # setup debug draw
      @debugDraw = new b2.DebugDraw()
      @debugDraw.SetFlags(b2.DebugDraw.e_shapeBit | b2.DebugDraw.e_jointBit)
      @alpha = 1
      @fillAlpha = 1

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

    render: (keysPressed, mouse) =>
      @game.world.SetDebugDraw(@debugDraw)

      # these two must go together in order to make @center.SetV work
      @lookAt(@game.you.GetPosition())
      @center.SetV(@worldVec2(new b2.Vec2(mouse.x, mouse.y)))

      @debugDraw.SetSprite(@cq.context)

      @cq.clear()
      @cq.context.save()

      # convert cq's transform into world coordinates
      @cq
      .translate(
        @cq.canvas.width/2 - @center.x * @scale(),
        @cq.canvas.height/2 - @center.y * @scale())
      .scale(@scale(), @scale())
      .lineWidth(0.025)

      @cq.fillStyle("#ffffff")
      # @cq.context.globalCompositeOperation = "source-over"
      # draw the vision poly in white
      @cq.beginPath()
      @cq.lineTo(point.x, point.y) for point in @game.you.getVisionPoly()
      @cq.fill()

      # @cq.context.globalCompositeOperation = "source-atop"
      for body in @game.getBodies()
        xf = body.m_xf
        for fixture in @game.getFixturesOf(body)
          shape = fixture.GetShape()
          @drawShape(shape, xf, body.GetUserData()?.color() || "black")

      # draw all particles
      @cq.context.save()
      for particle in @game.particles
        particle(@cq)
      @cq.context.restore()

      # restore global context
      @cq.context.restore()

    drawShape: (shape, xf, color) =>
      switch shape.m_type
        when b2.Shape.e_circleShape
          circle = shape
          center = b2.Math.MulX(xf, circle.m_p)
          radius = circle.m_radius
          axis = xf.R.col1
          @drawSolidCircle(center, radius, axis, color)
        when b2.Shape.e_polygonShape
          vertices = (b2.Math.MulX(xf, v) for v in shape.GetVertices())
          @drawSolidPolygon(vertices, color)
        when b2.Shape.e_edgeShape
          edge = shape
          @drawSegment(b2.Math.MulX(xf, edge.GetVertex1()), b2.Math.MulX(xf, edge.GetVertex2()), color)

    drawSolidCircle: (center, radius, axis, color) =>
      return if not radius
      s = @cq.context
      drawScale = 1
      cx = center.x * drawScale
      cy = center.y * drawScale
      s.moveTo(0, 0)
      s.beginPath()
      s.strokeStyle = color
      s.fillStyle = color
      s.arc(cx, cy, radius * drawScale, 0, Math.PI * 2, true)
      s.moveTo(cx, cy)
      s.lineTo((center.x + axis.x * radius) * drawScale, (center.y + axis.y * radius) * drawScale)
      s.closePath()
      s.fill()
      s.stroke()

    drawSolidPolygon: (vertices, color) =>
      s = @cq.context
      s.beginPath()
      s.strokeStyle = color
      s.fillStyle = color
      s.moveTo(vertices[0].x , vertices[0].y )
      s.lineTo(v.x , v.y) for v in vertices[1..]
      s.lineTo(vertices[0].x , vertices[0].y )
      s.closePath()
      s.fill()
      s.stroke()



  return Renderer
