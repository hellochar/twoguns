define [
  'jquery',
  'underscore',
  'b2',
  'noise',
  'stats',
  'multi_contact_listener'
  'game/world/block_userdata'
  'game/world/bullet_userdata'
  'game/world/player_userdata'
], ($, _, b2, ClassicalNoise, Stats, MultiContactListener, BlockUserData, BulletUserData, PlayerUserData) ->

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
    create: (player, height = 0.6, width = 0.2) =>
      game = player.game
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

        @player = player
        @game = game
        @world = @game.world

        # angle you are looking at
        @facing = 0

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


        @calculateVisionPoly()
      ).bind(body)()
      body.SetUserData(new PlayerUserData(body))
      return body
  }

  # do NOT declare these with -> or bind them; they will be
  # dynamically bound at runtime to the created body
  pbMethods = {
    canJump: ->
      @jumpCounter > 0

    getVisionPoly: () ->
      return @visionPoly

    # private
    calculateVisionPoly: () ->
      poly = []
      for angle in [0..Math.PI*2] by (Math.PI*2) / 200
        dir = new b2.Vec2(Math.cos(angle), Math.sin(angle))
        isect = @game.rayIntersect(@GetWorldCenter(), dir,
          (fixture) => fixture.GetBody() isnt this and not (fixture.GetBody().GetUserData() instanceof BulletUserData),
          100
        )
        isect?.fixture?.GetBody()?.GetUserData()?.visible = true
        point = isect?.point
        # either intersect or go out to 100 world units (longer than the screen length most likely)
        if not point
          point = @GetWorldCenter().Copy()
          offset = dir.Copy()
          offset.Multiply(100)
          point.Add(offset)
        poly.push(point)
      @visionPoly = poly

    shoot: (bulletType) ->
      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true

      bodyDef.position.SetV(@GetWorldCenter())
      positionOffset = @direction.Copy()
      DISTANCE_OFFSET = .5
      positionOffset.Multiply(DISTANCE_OFFSET)
      bodyDef.position.Add(positionOffset)

      BULLET_SPEED = 50
      bodyDef.linearVelocity.SetV(@direction)
      bodyDef.linearVelocity.Multiply(BULLET_SPEED)

      body = @world.CreateBody(bodyDef)
      body.SetUserData(new BulletUserData(body))

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

          if otherFixture.GetBody().GetUserData() instanceof BlockUserData
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
