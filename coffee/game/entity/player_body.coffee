define [
  'jquery',
  'underscore',
  'b2',
  'game/bullet'
  'game/world/bullet_userdata'
], ($, _, b2, Bullet, BulletUserData) ->

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

        FEET_HEIGHT = 0.001
        FEET_WIDTH = width / 2 - .005

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

        # normalized vector representing the angle you are looking at
        @direction = new b2.Vec2(1, 0)

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

    getVisionPoly: () ->
      @calculateVisionPoly() unless @visionPoly?
      return @visionPoly

    # private
    calculateVisionPoly: () ->
      poly = []
      @collidedBodies = []
      for angle in [0..Math.PI*2] by (Math.PI*2) / 200
        dir = new b2.Vec2(Math.cos(angle), Math.sin(angle))
        isect = @game.rayIntersect(@GetWorldCenter(), dir,
          (fixture) => fixture.GetBody() isnt this and not (fixture.GetBody().GetUserData() instanceof BulletUserData),
          30
        )
        @collidedBodies.push(isect?.fixture.GetBody())
        point = isect?.point
        # either intersect or go out to 100 world units (longer than the screen length most likely)
        if not point
          point = @GetWorldCenter().Copy()
          offset = dir.Copy()
          offset.Multiply(30)
          point.Add(offset)
        poly.push(point)
      @visionPoly = poly

    shoot: (bulletType) ->
      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true

      pos = @GetWorldCenter().Copy()
      positionOffset = @direction.Copy()
      DISTANCE_OFFSET = .5
      positionOffset.Multiply(DISTANCE_OFFSET)
      pos.Add(positionOffset)

      new Bullet(@player, pos, @direction, bulletType)
  }

  return PlayerBody
