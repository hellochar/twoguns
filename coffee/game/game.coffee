define ['b2', 'noise', 'stats'], (b2, ClassicalNoise, Stats) ->
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

      fixDef = new b2.FixtureDef
      fixDef.density = 1.0
      fixDef.friction = 0.5
      fixDef.restitution = 0.2

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

    makePlayerCharacter: () =>
      bodyDef = new b2.BodyDef
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.position.Set(0, 0)
      #  bodyDef.fixedRotation = true
      bodyDef.angularDamping = 5

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef

      #  main body/torso
      fixDef.density = 1.0
      fixDef.friction = 0.8
      fixDef.restitution = -10
      fixDef.shape = new b2.PolygonShape
      fixDef.shape.SetAsBox( .2 / 2, 1.7 / 2 )

      body.CreateFixture(fixDef)

      #  feet sensor
      fixDef.isSensor = true
      fixDef.shape.SetAsEdge(new b2.Vec2( -.2 / 2, 1.7 / 2), new b2.Vec2( +.2 / 2, 1.7 / 2 ) )
      body.feet = body.CreateFixture(fixDef)

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
      # todo make player respond to input
      #  canJump = (function() {
      #    for(ce = @you.GetContactList() ce ce = ce.next) {
      #      c = ce.contact
      #      if(c.
      #    }
      #  })()
      POWER = .3
      loc = @you.GetWorldPoint(new b2.Vec2(0, -.5))
      if 'w' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(0, -POWER), loc)

      if 'a' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(-POWER, 0), loc)

      if 's' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(0, POWER), loc)

      if 'd' of keysPressed
        @you.ApplyImpulse(new b2.Vec2(POWER, 0), loc)

      @world.Step(1 / 30, 10, 10)
      @world.ClearForces()


  return Game
