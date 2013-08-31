define [
  'jquery',
  'underscore',
  'b2',
  'noise',
  'stats',
  'multi_contact_listener'
], ($, _, b2, ClassicalNoise, Stats, MultiContactListener) ->

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
    create: (game, height = 0.6, width = 0.2) =>
      body = game.world.CreateBody(BODYDEF)

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

        @game = game
        @world = @game.world

        @jumpCounter = 0
        $(@feet).on("begincontact", (evt, contact, myFixture, otherFixture) =>
          @jumpCounter += 1
        )
        $(@feet).on("endcontact", (evt, contact, myFixture, otherFixture) =>
          @jumpCounter -= 1
        )

        @bullets = []

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
      IMPULSE_JUMP = new b2.Vec2(0, -0.04 / @GetMass())
      FORCE_WALK_X = 4.0
      # FORCE_FLY = new b2.Vec2(0, -0.8 * @world.GetGravity().y)
      FORCE_FLY = new b2.Vec2(0, -0.8)
      loc = @GetWorldCenter()

      if 'w' of keysPressed and @canJump()
        @ApplyImpulse(IMPULSE_JUMP, loc)

      if 'space' of keysPressed
        @ApplyForce(FORCE_FLY, loc)

      vel = @GetLinearVelocity()

      if 'a' of keysPressed
        @SetLinearVelocity(new b2.Vec2(-FORCE_WALK_X, vel.y))
      else if 'd' of keysPressed
        @SetLinearVelocity(new b2.Vec2(FORCE_WALK_X, vel.y))
      else
        @SetLinearVelocity(new b2.Vec2(0, vel.y))

      if 's' of keysPressed
        @ApplyImpulse(new b2.Vec2(0, IMPULSE_JUMP / 10), loc)

      bullet.ApplyForce(@world.GetGravity().GetNegative(), bullet.GetWorldCenter()) for bullet in @bullets

      direction = @directionTo(mouse.location)
      point2 = @GetWorldCenter().Copy()
      direction.Multiply(100)
      point2.Add(direction)
      sightline = ( =>
        isect = @world.rayIntersect(@GetWorldCenter(), direction,
          (fixture) -> fixture.GetBody().GetUserData() is "block"
        )
        if isect
          return (cq) =>
            cq.fillStyle("red").circle(isect.point.x, isect.point.y, 0.05).fill()
            cq.strokeStyle("red").beginPath().
              moveTo(@GetWorldCenter().x, @GetWorldCenter().y).
              lineTo(isect.point.x, isect.point.y).
              stroke()
        else
          undefined
      )()
      @game.particles.push(sightline) if sightline

    directionTo: (x, y) ->
      if "x" of x and "y" of x and y == undefined
        {x: x, y: y} = x

      direction = new b2.Vec2(x, y)
      direction.Subtract(@GetWorldCenter())
      direction.Normalize()

      direction

    shootAt: (location, bulletType) ->
      direction = @directionTo(location)

      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true

      bodyDef.position.SetV(@GetWorldCenter())
      positionOffset = direction.Copy()
      DISTANCE_OFFSET = .5
      positionOffset.Multiply(DISTANCE_OFFSET)
      bodyDef.position.Add(positionOffset)

      BULLET_SPEED = 10
      bodyDef.linearVelocity.SetV(direction)
      bodyDef.linearVelocity.Multiply(BULLET_SPEED)

      body = @world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef()
      fixDef.density = 0.0
      fixDef.friction = 0.0
      fixDef.restitution = 0
      # fixDef.isSensor = true
      fixDef.shape = new b2.CircleShape(.05)

      body.CreateFixture(fixDef)

      $(body).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        if contact.IsTouching()
          @game.delegates.push( =>
            @world.DestroyBody(body)
            @bullets = _.without(@bullets, body)
          )
          $(body).off("begincontact")

          if otherFixture.GetBody().GetUserData() is "block"
            if bulletType is "create"
              @game.delegates.push(=>@world.DestroyBody(otherFixture.GetBody()))
            else if bulletType is "destroy"
              @game.delegates.push(=>
                blockCenter = body.GetWorldCenter()
                direction = contact.GetManifold().m_localPoint
                length = direction.Normalize()
                direction.Multiply(length - fixDef.shape.GetRadius())
                blockCenter.Add(direction)
                @game.createBlock(blockCenter.x, blockCenter.y)
              )

      )

      @bullets.push(body)


  }

  return PlayerBody
