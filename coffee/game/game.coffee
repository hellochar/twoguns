define [
  'jquery',
  'underscore',
  'b2',
  'noise',
  'stats',
  'multi_contact_listener',
  'game/player_body'
], ($, _, b2, ClassicalNoise, Stats, MultiContactListener, PlayerBody) ->
  # model of the game
  #
  #   there is a physics world, with objects etc.
  #   there are players within the physics world
  #   there are bullets owned by players
  #   there is a win/lose condition

  class Game

    BLOCK_BODYDEF = new b2.BodyDef
    BLOCK_BODYDEF.type = b2.Body.b2_staticBody

    BLOCK_FIXDEF = new b2.FixtureDef
    BLOCK_FIXDEF.density = 1
    BLOCK_FIXDEF.friction = 1
    BLOCK_FIXDEF.restitution = 0
    BLOCK_FIXDEF.shape = new b2.PolygonShape

    constructor: (@width, @height, @gridSize) ->
      world = @world = new b2.World(
        new b2.Vec2(0, 8)  # gravity
        ,  true         # allow sleep
        )

      world.rayIntersectAll = (point1, dir, filter) ->
        arr = []
        point2 = point1.Copy()
        offset = dir.Copy()
        offset.Multiply(10000)
        point2.Add(offset)

        @RayCast((fixture, point, normal, fraction) =>
          if !(filter?) or filter?(fixture, point, normal, fraction)
            arr.push(
              fixture: fixture
              point: point
              normal: normal
              fraction: fraction
            )
          return 1
        , point1, point2)

        arr

      world.rayIntersect = (point1, dir, filter) ->
        arr = world.rayIntersectAll(point1, dir, filter)

        if arr.length > 0
          _.min(arr, (obj) =>
            offset = obj.point.Copy()
            offset.Subtract(point1)
            offset.LengthSquared()
          )
        else
          undefined


      window.mcl = new MultiContactListener(world)

      # create top/bottom
      BLOCK_FIXDEF.shape.SetAsBox(width/2, 1)
      BLOCK_BODYDEF.position.Set(0, -( height/2 + 1 ) )
      world.CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)
      BLOCK_BODYDEF.position.Set(0, +( height/2 + 1 ) )
      world.CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)

      # create left/right
      BLOCK_FIXDEF.shape.SetAsBox(1, height/2)
      BLOCK_BODYDEF.position.Set(-( width/2 + 1 ), 0)
      world.CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)
      BLOCK_BODYDEF.position.Set(+( width/2 + 1 ), 0)
      world.CreateBody(BLOCK_BODYDEF).CreateFixture(BLOCK_FIXDEF)

      # create you
      @you = PlayerBody.create(@)

      # create platform boxes
      @noise = new ClassicalNoise()
      @generateNoiseBoxes(3)

      # callbacks to be invoked right before the game steps
      @delegates = []

      @particles = []

    #
    # noiseScalar:
    #   between 1 and 2 produces a dense maze-like structure (it seems that any 1 < n < 2 has the same characteristics)
    #   exactly 2 produces quite thin lines, somewhat sparse
    #   after 2 the usual noisey-ness comes into play
    #
    #
    generateNoiseBoxes: (noiseScalar) =>
      BLOCK_FIXDEF.shape.SetAsBox(@gridSize / 2, @gridSize / 2)
      for x in [-@width/2...@width/2] by @gridSize
        for y in [-@height/2...@height/2] by @gridSize
          if (@noise.noise(x/noiseScalar, y/noiseScalar, 0) + 1) / 2 < .5
            @createBlock(x + @gridSize / 2, y + @gridSize / 2)
            # query neighbors, create contacts

    createBlock: (x, y, isStatic) =>
      isStatic ?= true
      BLOCK_BODYDEF.type = if isStatic then b2.Body.b2_staticBody else b2.Body.b2_dynamicBody
      BLOCK_BODYDEF.position.Set( x, y )
      block = @world.CreateBody(BLOCK_BODYDEF)
      fixture = block.CreateFixture(BLOCK_FIXDEF)
      block.SetUserData("block")

    step: (keysPressed, mouse, delta) =>
      @particles = []

      @you.update(keysPressed, mouse)

      method() for method in @delegates
      @delegates = []
      @world.Step(delta / 1000, 10, 10)
      @world.ClearForces()

    mouseDown: (location, button) =>
      @you.shootAt(location, {0: "create", 2: "destroy"}[button])




  return Game
