define [
  'b2',
  'multi_contact_listener'
], (b2, MultiContactListener) ->


  BLOCK_BODYDEF = new b2.BodyDef
  BLOCK_BODYDEF.type = b2.Body.b2_staticBody

  BLOCK_FIXDEF = new b2.FixtureDef
  BLOCK_FIXDEF.density = 1
  BLOCK_FIXDEF.friction = 1
  BLOCK_FIXDEF.restitution = 0
  BLOCK_FIXDEF.shape = new b2.PolygonShape


  class GameWorld extends b2.World
    constructor: (gravity, allowSleep, @game) ->
      super(gravity, allowSleep)
      this.b2World.apply(this, [gravity, allowSleep])
      @SetContactListener(new MultiContactListener())
      @createBoundingBoxes(@game.width, @game.height)
      @generateNoiseBoxes(3, @game.gridSize)

    # noiseScalar:
    #   between 1 and 2 produces a dense maze-like structure (it seems that any 1 < n < 2 has the same characteristics)
    #   exactly 2 produces quite thin lines, somewhat sparse
    #   after 2 the usual noisey-ness comes into play
    generateNoiseBoxes: (noiseScalar, gridSize) =>
      BLOCK_FIXDEF.shape.SetAsBox(gridSize / 2, gridSize / 2)
      for x in [-@game.width/2...@game.width/2] by gridSize
        for y in [-@game.height/2...@game.height/2] by gridSize

          if (@game.random.perlin(x/noiseScalar, y/noiseScalar, 0) + 1) / 2 < .5
            @createBlock(x + gridSize / 2, y + gridSize / 2)
            # todo: query neighbors, create contacts? e.g. make blocks free-falling?

    createBlock: (x, y, isStatic = true) =>
      BLOCK_BODYDEF.type = if isStatic then b2.Body.b2_staticBody else b2.Body.b2_dynamicBody
      BLOCK_BODYDEF.position.Set( x, y )
      block = @CreateBody(BLOCK_BODYDEF)
      fixture = block.CreateFixture(BLOCK_FIXDEF)
      block.SetUserData("block")

      block

    createBoundingBoxes: (width, height) =>
      # create top/bottom
      BLOCK_FIXDEF.shape.SetAsBox(width/2, 1)
      BLOCK_BODYDEF.position.Set(0, -( height/2 + 1 ) )
      @CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)
      BLOCK_BODYDEF.position.Set(0, +( height/2 + 1 ) )
      @CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)

      # create left/right
      BLOCK_FIXDEF.shape.SetAsBox(1, height/2)
      BLOCK_BODYDEF.position.Set(-( width/2 + 1 ), 0)
      @CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)
      BLOCK_BODYDEF.position.Set(+( width/2 + 1 ), 0)
      @CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)



  return GameWorld
