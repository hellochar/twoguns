define ['jquery', 'underscore', 'b2', 'noise', 'stats', 'multi_contact_listener', 'game/player_body'], ($, _, b2, ClassicalNoise, Stats, MultiContactListener, PlayerBody) ->
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
      @you = PlayerBody.create(@world)

      # create platform boxes
      @noise = new ClassicalNoise()
      @generateNoiseBoxes(3)

      #array of b2.Body's that are my bullets
      @bullets = []

      # callbacks to be invoked right before the game steps
      @delegates = []

      # an array of {location: (x, y)} objects that denote where particles live
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
      @you.update(keysPressed, mouse)

      direction = @you.directionTo(mouse.location)
      point2 = @you.GetWorldCenter().Copy()
      direction.Multiply(100)
      point2.Add(direction)

      @particles = []
      @world.RayCast((fixture, point, normal, fraction) =>
        @particles.push({
          location: point
          direction: normal
        })
        return 1
      , @you.GetWorldCenter(), point2)

      method() for method in @delegates
      @delegates = []

      bullet.ApplyForce(@world.GetGravity().GetNegative(), bullet.GetWorldCenter()) for bullet in @bullets

      @world.Step(delta / 1000, 10, 10)
      @world.ClearForces()

    mouseDown: (location, button) =>
      direction = @you.directionTo(location)

      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true

      bodyDef.position.SetV(@you.GetWorldCenter())
      positionOffset = direction.Copy()
      DISTANCE_OFFSET = .2
      positionOffset.Multiply(DISTANCE_OFFSET)
      bodyDef.position.Add(positionOffset)

      BULLET_SPEED = 10
      bodyDef.linearVelocity.SetV(direction)
      bodyDef.linearVelocity.Multiply(BULLET_SPEED)
      bodyDef.linearVelocity.Add(@you.GetLinearVelocity())

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef()
      fixDef.density = 0.0
      fixDef.friction = 0.0
      fixDef.restitution = 0
      # fixDef.isSensor = true
      fixDef.shape = new b2.CircleShape(.05)

      body.CreateFixture(fixDef)

      $(body).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        if contact.IsTouching() and otherFixture.GetBody().GetUserData() is "block"
          @delegates.push(=>@world.DestroyBody(body))
          if button is 0
            @delegates.push(=>@world.DestroyBody(otherFixture.GetBody()))
          else if button is 2
            @delegates.push(=>
              blockCenter = body.GetWorldCenter()
              direction = contact.GetManifold().m_localPoint
              length = direction.Normalize()
              direction.Multiply(length - fixDef.shape.GetRadius())
              blockCenter.Add(direction)
              @createBlock(blockCenter.x, blockCenter.y)
            )

          @bullets = _.without(@bullets, body)
          $(body).off("begincontact")
      )

      @bullets.push(body)





  return Game
