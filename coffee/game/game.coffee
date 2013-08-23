define ['jquery', 'underscore', 'b2', 'noise', 'stats', 'multi_contact_listener'], ($, _, b2, ClassicalNoise, Stats, MultiContactListener) ->
  # model of the game
  #
  #   there is a physics world, with objects etc.
  #   there are players within the physics world
  #   there are bullets owned by players
  #   there is a win/lose condition

  class Game
    constructor: (@width, @height, @gridSize) ->
      world = @world = new b2.World(
        new b2.Vec2(0, 8)  # gravity
        ,  true         # allow sleep
        )

      window.mcl = new MultiContactListener(world)

      fixDef = new b2.FixtureDef
      fixDef.density = 1.0
      fixDef.friction = 1
      fixDef.restitution = 0

      bodyDef = new b2.BodyDef


      # create bounding box
      bodyDef.type = b2.Body.b2_staticBody
      fixDef.shape = new b2.PolygonShape

      # create top/bottom
      fixDef.shape.SetAsBox(width/2, 1)
      bodyDef.position.Set(0, -( height/2 + 1 ) )
      world.CreateBody(bodyDef).CreateFixture(fixDef)
      bodyDef.position.Set(0, +( height/2 + 1 ) )
      world.CreateBody(bodyDef).CreateFixture(fixDef)

      # create left/right
      fixDef.shape.SetAsBox(1, height/2)
      bodyDef.position.Set(-( width/2 + 1 ), 0)
      world.CreateBody(bodyDef).CreateFixture(fixDef)
      bodyDef.position.Set(+( width/2 + 1 ), 0)
      world.CreateBody(bodyDef).CreateFixture(fixDef)

      # create you
      @you = @makePlayerCharacter()

      # create platform boxes
      bodyDef.position.Set(0, 0)
      bodyDef.type = b2.Body.b2_staticBody
      @platformBody = world.CreateBody(bodyDef)
      # platformBody.SetUserData({ class : 'platform' })

      bodyDef.userData = 'block'
      @noise = new ClassicalNoise()
      @generateNoiseBoxes(3, fixDef, bodyDef)

      #array of b2.Body's that are my bullets
      @bullets = []
      @toDestroy = []

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
    generateNoiseBoxes: (noiseScalar, fixDef, bodyDef) =>
      fixDef.shape.SetAsBox(@gridSize / 2, @gridSize / 2)
      for x in [-@width/2...@width/2] by @gridSize
        for y in [-@height/2...@height/2] by @gridSize
          if (@noise.noise(x/noiseScalar, y/noiseScalar, 0) + 1) / 2 < .5
            bodyDef.position.Set(x + @gridSize / 2, y + @gridSize / 2)
            @world.CreateBody(bodyDef).CreateFixture(fixDef)
            # query neighbors, create contacts

    step: (keysPressed, mouse, delta) =>
      FORCE_JUMP = 0.8
      FORCE_WALK = 3.5
      loc = @you.GetWorldPoint(new b2.Vec2(0, 0))

      if 'w' of keysPressed and @canJump > 0
        @you.ApplyImpulse(new b2.Vec2(0, -FORCE_JUMP), loc)

      if 'space' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(0, -.1), loc)

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


      @world.DestroyBody(body) for body in @toDestroy
      @toDestroy = []

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
          @toDestroy.push(body)
          @toDestroy.push(otherFixture.GetBody())
          @bullets = _.without(@bullets, body)
          $(body).off("begincontact")
      )

      @bullets.push(body)





  return Game
