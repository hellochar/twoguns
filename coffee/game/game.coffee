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
        new b2.Vec2(0, 10)  # gravity
        ,  true         # allow sleep
        )

      window.mcl = new MultiContactListener(world)

      fixDef = new b2.FixtureDef
      fixDef.density = 1.0
      fixDef.friction = 0.5
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

      @noise = new ClassicalNoise()
      @generateNoiseBoxes(3, fixDef, bodyDef)

      #array of b2.Body's that are my bullets
      @bullets = []
      @toDestroy = []

    makePlayerCharacter: (height = 1.7, width = 0.2) =>
      bodyDef = new b2.BodyDef
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.position.Set(0, 0)
      bodyDef.fixedRotation = true

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef

      #  main body/torso
      fixDef.density = 1.0
      fixDef.friction = 0.8
      fixDef.restitution = 0
      fixDef.shape = new b2.PolygonShape
      fixDef.shape.SetAsBox( width / 2, height / 2 )

      body.torso = body.CreateFixture(fixDef)

      #  feet sensor
      FEET_PADDING_BOTTOM = 0.01
      fixDef.isSensor = true
      fixDef.shape.SetAsEdge(new b2.Vec2( - width / 2.1, height / 2 + FEET_PADDING_BOTTOM), new b2.Vec2( +width / 2.1, height / 2 + FEET_PADDING_BOTTOM ) )
      body.feet = body.CreateFixture(fixDef)

      $(body.feet).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        @canJump = true
      )
      $(body.feet).on("endcontact", (evt, contact, myFixture, otherFixture) =>
        @canJump = false
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

    step: (keysPressed, mouse) =>

      POWER = .3
      loc = @you.GetWorldPoint(new b2.Vec2(0, 0))
      if @canJump
        if 'w' of keysPressed
          @you.ApplyImpulse(new b2.Vec2(0, -POWER * 4), loc)

      if 'a' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(-POWER, 0), loc)

      if 'd' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(POWER, 0), loc)

      if 's' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(0, POWER), loc)


      @world.DestroyBody(body) for body in @toDestroy
      @toDestroy = []

      @world.Step(1 / 30, 10, 10)
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

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef()
      fixDef.density = 0.0
      fixDef.friction = 0.0
      fixDef.restitution = 0
      fixDef.shape = new b2.CircleShape(.05)

      body.CreateFixture(fixDef)

      $(body).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        if contact.IsTouching() and otherFixture.GetBody() isnt @you
          @toDestroy.push(body)
          @toDestroy.push(otherFixture.GetBody())
          @bullets = _.without(@bullets, body)
          $(body).off("begincontact")
      )

      @bullets.push(body)





  return Game
