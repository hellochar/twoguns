define [
  'jquery',
  'underscore',
  'b2',
  'settings'
  'game/entity/bullet'
], ($, _, b2, settings, Bullet) ->

  BODYDEF = new b2.BodyDef
  BODYDEF.type = b2.Body.b2_dynamicBody
  BODYDEF.fixedRotation = true
  BODYDEF.allowSleep = false

  FIXDEF = new b2.FixtureDef
  FIXDEF.density = 1.0
  FIXDEF.friction = 0
  FIXDEF.restitution = 0
  FIXDEF.shape = new b2.PolygonShape

  PlayerBody = {
    create: (player, height = settings.player.height, width = settings.player.width) =>
      game = player.game
      # find a nice spot
      pos = game.findEmptyAABB(1, .5)
      BODYDEF.position.SetV(pos.lowerBound)
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
      for angle in [0..Math.PI*2] by (Math.PI*2) / settings.player.visionPolyDetail
        dir = new b2.Vec2(Math.cos(angle), Math.sin(angle))
        isect = @game.rayIntersect(@GetWorldCenter(), dir,
          (fixture) => fixture.GetBody() isnt this and not (fixture.GetBody().GetUserData() instanceof Bullet),
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
      @bullet_sound.currentTime = 0
      @bullet_sound.play()

      pos = @GetWorldCenter().Copy()
      positionOffset = @direction.Copy()
      DISTANCE_OFFSET = .5
      positionOffset.Multiply(DISTANCE_OFFSET)
      pos.Add(positionOffset)

      new Bullet(@player, pos, @direction, bulletType)
  }

  return PlayerBody
