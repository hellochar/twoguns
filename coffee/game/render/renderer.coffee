define [
  'b2'
  'utils'
  'game/world/bullet_userdata'
  'game/render/image_cache'
], (b2, Utils, BulletUserData, ImageCache) ->

  class Renderer
    constructor: (@viewportWidth, @game, @cq) ->
      @center = new b2.Vec2() # world coordinates
      $(@cq.canvas).css('background-color', 'black')

    lookAt: (center) => @center.SetV(center)

    # Move the renderer window by the given world offset
    translate: (delta) => @center.Add(delta)

    # convert the given screen location to its corresponding location on the screen
    worldVec2: (screenVec2) =>
      worldVec2 = screenVec2.Copy()
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

    #mouse x and y in screen coordinates; still needed for now but should be removed soon
    render: (mx, my) =>
      @game.youPlayer.lookAt(this, mx, my)

      @cq.clear()
      @cq.context.save()

      # convert cq's transform into world coordinates
      @cq
      .translate(
        @cq.canvas.width/2 - @center.x * @scale(),
        @cq.canvas.height/2 - @center.y * @scale())
      .scale(@scale(), @scale())
      .lineWidth(1 / @scale())

      @cq.fillStyle("white").globalCompositeOperation("source-over")
      # draw the vision poly in white
      @cq.beginPath()
      @cq.lineTo(point.x, point.y) for point in @game.youPlayer.getVisionPoly()
      @cq.fill()

      # draw the background that you can see
      @cq.context.globalCompositeOperation = "source-atop"
      @cq.context.save()
      @cq.scale(.2, .2)
      @cq.drawImage(ImageCache.get('img/bg.jpg'), -400, -920)
      @cq.context.restore()

      # draw the rest of the background
      @cq.globalCompositeOperation("destination-over")
      @cq.context.save()
      @cq.scale(.2, .2)
      @cq.drawImage(ImageCache.get('img/bg-novision.jpg'), -400, -920)
      @cq.context.restore()

      @cq.globalCompositeOperation("source-over")


      # @cq.context.globalCompositeOperation = "source-atop"
      # @drawBody(body) for body in @game.getBodies()
      # cull off-screen bodies
      @drawBody(body) for body in @game.getBodiesInAABB(@visibleAABB())
      # @game.world.QueryAABB(((fixture) => @drawBody(fixture.GetBody())), @visibleAABB())

      # draw sightline
      isect = @game.rayIntersect(@game.youPlayer.playerBody.GetWorldCenter(), @game.youPlayer.playerBody.direction,
        (fixture) -> not (fixture.GetBody().GetUserData() instanceof BulletUserData)
      )
      if isect
        @cq.fillStyle("red").beginPath().circle(isect.point.x, isect.point.y, 0.035).fill()
        @cq.strokeStyle("rgba(255, 0, 0, 0.3)").beginPath().
          moveTo(@game.youPlayer.playerBody.GetWorldCenter().x, @game.youPlayer.playerBody.GetWorldCenter().y).
          lineTo(isect.point.x, isect.point.y).
          stroke()

      # restore global context
      @cq.context.restore()

    drawBody: (body) =>
      body.GetUserData()?.draw(this, => @drawBodyDefault(body)) || @drawBodyDefault(body)

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
