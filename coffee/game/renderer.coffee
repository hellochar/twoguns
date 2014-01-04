define ['b2', 'utils'], (b2, Utils) ->

  class Renderer
    constructor: (@viewportWidth, @game, @cq) ->
      @center = new b2.Vec2() # world coordinates
      @bgImage = new Image()
      @bgImage.src = 'img/bg.jpg'

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

    scale: () => @cq.canvas.width / @viewportWidth

    visibleAABB: () =>
      aabb = new b2.AABB()
      aabb.lowerBound = @worldVec2(new b2.Vec2(0, 0))
      aabb.upperBound = @worldVec2(new b2.Vec2(@cq.canvas.width, @cq.canvas.height))
      return aabb

    render: (keysPressed, mouse) =>
      # these two must go together in order to make @center.SetV work
      @lookAt(@game.you.GetPosition())
      @center.SetV(@worldVec2(new b2.Vec2(mouse.x, mouse.y)))

      @cq.clear("rgb(128, 128, 128)")
      @cq.context.save()

      # convert cq's transform into world coordinates
      @cq
      .translate(
        @cq.canvas.width/2 - @center.x * @scale(),
        @cq.canvas.height/2 - @center.y * @scale())
      .scale(@scale(), @scale())
      .lineWidth(1 / @scale())

      @cq.context.save()
      @cq.scale(.2, .2)
      @cq.translate(@center.x * 1, @center.y * 1)
      @cq.drawImage(@bgImage, -400, -420)
      @cq.context.save()
      @cq.context.setTransform(1, 0, 0, 1, 0, 0)
      @cq.clear("rgba(0, 0, 0, .5)")
      @cq.context.restore()
      @cq.context.restore()

      @cq.fillStyle("rgba(255, 255, 255, .8)")
      # @cq.context.globalCompositeOperation = "source-over"
      # draw the vision poly in white
      @cq.beginPath()
      @cq.lineTo(point.x, point.y) for point in @game.you.getVisionPoly()
      @cq.fill()

      # @cq.context.globalCompositeOperation = "source-atop"
      # @drawBody(body) for body in @game.getBodies()
      # cull off-screen bodies
      @drawBody(body) for body in @game.getBodiesInAABB(@visibleAABB())
      # @game.world.QueryAABB(((fixture) => @drawBody(fixture.GetBody())), @visibleAABB())

      # draw all particles
      @cq.context.save()
      for particle in @game.particles
        particle(@cq)
      @cq.context.restore()

      # restore global context
      @cq.context.restore()

    drawBody: (body) =>
      body.GetUserData()?.draw(this, => @drawBodyDefault(body))
    drawBodyDefault: (body) =>
      xf = body.m_xf
      color = body.GetUserData()?.color() || "black"
      for fixture in @game.getFixturesOf(body)
        shape = fixture.GetShape()
        @drawShape(shape, xf, color)

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
