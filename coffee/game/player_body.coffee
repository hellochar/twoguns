define [
  'jquery',
  'underscore',
  'b2',
  'noise',
  'stats',
  'multi_contact_listener'
  ],
  ($, _, b2, ClassicalNoise, Stats, MultiContactListener) ->

    BODYDEF = new b2.BodyDef
    BODYDEF.type = b2.Body.b2_dynamicBody
    BODYDEF.position.Set(0, 0)
    BODYDEF.fixedRotation = true
    BODYDEF.allowSleep = false

    FIXDEF = new b2.FixtureDef
    FIXDEF.density = 1.0
    FIXDEF.friction = 0
    FIXDEF.restitution = 0
    FIXDEF.shape = new b2.PolygonShape

    PlayerBody = {
      create: (world, height = 1.3, width = 0.2) =>
        body = world.CreateBody(BODYDEF)

        (->
          FIXDEF.shape.SetAsBox( width / 2, height / 2 )
          @torso = @CreateFixture(FIXDEF)

          FEET_HEIGHT = 0.01
          FEET_WIDTH = width / 2 - .01

          FIXDEF.shape.SetAsVector([
            new b2.Vec2(FEET_WIDTH, height / 2),
            new b2.Vec2(FEET_WIDTH, height / 2 + FEET_HEIGHT),
            new b2.Vec2(-FEET_WIDTH, height / 2 + FEET_HEIGHT),
            new b2.Vec2(-FEET_WIDTH, height / 2)
          ])
          @feet = @CreateFixture(FIXDEF)

          @jumpCounter = 0
          $(@feet).on("begincontact", (evt, contact, myFixture, otherFixture) =>
            @jumpCounter += 1
          )
          $(@feet).on("endcontact", (evt, contact, myFixture, otherFixture) =>
            @jumpCounter -= 1
          )

          for methodName, impl of pbMethods
            @[methodName] = impl.bind(@)
        ).bind(body)()
        return body
    }

    # do NOT declare these with -> or bind them; they will be
    # dynamically bound at runtime to the created body
    pbMethods = {
      canJump: ->
        @jumpCounter > 0

      update: (keysPressed, mouse) ->
        FORCE_JUMP = new b2.Vec2(0, -0.8)
        FORCE_WALK_X = 4.0
        FORCE_FLY = new b2.Vec2(0, -0.05)
        loc = @GetWorldCenter()

        if 'w' of keysPressed and @canJump()
          @ApplyImpulse(FORCE_JUMP, loc)

        if 'space' of keysPressed
          @ApplyImpulse(FORCE_FLY, loc)

        vel = @GetLinearVelocity()

        if 'a' of keysPressed
          @SetLinearVelocity(new b2.Vec2(-FORCE_WALK_X, vel.y))
        else if 'd' of keysPressed
          @SetLinearVelocity(new b2.Vec2(FORCE_WALK_X, vel.y))
        else
          @SetLinearVelocity(new b2.Vec2(0, vel.y))

        if 's' of keysPressed
          @ApplyImpulse(new b2.Vec2(0, FORCE_JUMP / 10), loc)

      directionTo: (x, y) ->
        if "x" of x and "y" of x and y == undefined
          {x: x, y: y} = x

        direction = new b2.Vec2(x, y)
        direction.Subtract(@GetWorldCenter())
        direction.Normalize()

        direction

    }

    return PlayerBody
