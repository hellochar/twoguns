define ['jquery', 'underscore', 'b2', 'noise', 'stats', 'multi_contact_listener'], ($, _, b2, ClassicalNoise, Stats, MultiContactListener) ->
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
      @you = @makePlayerCharacter()

      # create platform boxes
      @noise = new ClassicalNoise()
      @generateNoiseBoxes(3)

      #array of b2.Body's that are my bullets
      @bullets = []

      @delegates = []

    makePlayerCharacter: (height = 1.3, width = 0.2) =>
      bodyDef = new b2.BodyDef
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.position.Set(0, 0)
      bodyDef.fixedRotation = true
      bodyDef.allowSleep = false

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef

      #  main body/torso
      fixDef.density = 1.0
      fixDef.friction = 0
      fixDef.restitution = 0
      fixDef.shape = new b2.PolygonShape
      fixDef.shape.SetAsBox( width / 2, height / 2 )

      body.torso = body.CreateFixture(fixDef)

      FEET_HEIGHT = 0.01
      FEET_WIDTH = width / 2 - .01
      fixDef.shape.SetAsVector([
        new b2.Vec2(FEET_WIDTH, height / 2),
        new b2.Vec2(FEET_WIDTH, height / 2 + FEET_HEIGHT),
        new b2.Vec2(-FEET_WIDTH, height / 2 + FEET_HEIGHT),
        new b2.Vec2(-FEET_WIDTH, height / 2)
      ])
      fixDef.friction = 0
      body.feet = body.CreateFixture(fixDef)

      @canJump = 0
      $(body.feet).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        @canJump += 1
      )
      $(body.feet).on("endcontact", (evt, contact, myFixture, otherFixture) =>
        @canJump -= 1
      )

      body


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
            @createBlock(x, y)
            # query neighbors, create contacts

    createBlock: (x, y) =>
      BLOCK_BODYDEF.position.Set(x + @gridSize / 2, y + @gridSize / 2)
      block = @world.CreateBody(BLOCK_BODYDEF)
      fixture = block.CreateFixture(BLOCK_FIXDEF)
      block.SetUserData("block")


    step: (keysPressed, mouse, delta) =>
      FORCE_JUMP = 0.8
      FORCE_WALK = 4.0
      FORCE_FLY = 0.05
      loc = @you.GetWorldPoint(new b2.Vec2(0, 0))

      if 'w' of keysPressed and @canJump > 0
        @you.ApplyImpulse(new b2.Vec2(0, -FORCE_JUMP), loc)

      if 'space' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(0, -FORCE_FLY), loc)

      vel = @you.GetLinearVelocity()

      if 'a' of keysPressed
        # force = Math.min(Math.max(-FORCE_WALK, -FORCE_WALK - vel.x), 0)
        # @you.ApplyImpulse(new b2.Vec2(force, 0), loc)
        @you.SetLinearVelocity(new b2.Vec2(-FORCE_WALK, vel.y))
      else if 'd' of keysPressed
        # force = Math.max(Math.min(FORCE_WALK, FORCE_WALK - vel.x), 0)
        # @you.ApplyImpulse(new b2.Vec2(force, 0), loc)
        @you.SetLinearVelocity(new b2.Vec2(FORCE_WALK, vel.y))
      else
        @you.SetLinearVelocity(new b2.Vec2(0, vel.y))

      if 's' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(0, FORCE_JUMP / 10), loc)


      method() for method in @delegates
      @delegates = []

      @world.Step(delta / 1000, 10, 10)
      @world.ClearForces()

    mouseDown: (location, button) =>
      offset = new b2.Vec2()
      offset.SetV(location)
      offset.Subtract(@you.GetWorldCenter())


      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true

      bodyDef.position.SetV(@you.GetWorldCenter())
      positionOffset = offset.Copy()
      DISTANCE_OFFSET = .2
      positionOffset.Multiply(DISTANCE_OFFSET / positionOffset.Length())
      bodyDef.position.Add(positionOffset)

      BULLET_SPEED = 10
      bodyDef.linearVelocity.SetV(offset)
      bodyDef.linearVelocity.Multiply(BULLET_SPEED / bodyDef.linearVelocity.Length())
      bodyDef.linearVelocity.Add(@you.GetLinearVelocity())

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef()
      fixDef.density = 0.0
      fixDef.friction = 0.0
      fixDef.restitution = 0
      fixDef.shape = new b2.CircleShape(.05)

      body.CreateFixture(fixDef)

      $(body).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        if contact.IsTouching() and otherFixture.GetBody().GetUserData() is "block"
          @delegates.push(=>@world.DestroyBody(body))
          if button is 0
            @delegates.push(=>@world.DestroyBody(otherFixture.GetBody()))
          else if button is 2
            @delegates.push(=>
              @createBlock(body.GetWorldCenter().x, body.GetWorldCenter().y)
            )

          @bullets = _.without(@bullets, body)
          $(body).off("begincontact")
      )

      @bullets.push(body)





  return Game
