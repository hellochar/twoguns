define [
  'b2',
  'multi_contact_listener'
  'game/entity/wall'
  'game/entity/block'
], (b2, MultiContactListener, Wall, Block) ->


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
      # this following line is a hack to call the rest of the super constructor correctly
      this.b2World.apply(this, [gravity, allowSleep])

      @SetContactListener(new MultiContactListener())

    createMap: () =>
      @createBoundingBoxes(@game.width, @game.height)
      @generateNoiseBoxes(3, 1)

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
      new Block(@game, new b2.Vec2(x, y), 1, isStatic)

    createBoundingBoxes: (width, height) =>
      # create top/bottom
      new Wall(@game, new b2.Vec2(0, -( height/2 + 1 ) ), width/2 + 1/2, 1)
      new Wall(@game, new b2.Vec2(0, +( height/2 + 1 ) ), width/2 + 1/2, 1)

      # create left/right
      new Wall(@game, new b2.Vec2(-( width/2 + 1 ), 0), 1, height/2 + 1/2)
      new Wall(@game, new b2.Vec2(+( width/2 + 1 ), 0), 1, height/2 + 1/2)

  return GameWorld
