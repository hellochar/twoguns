define [
  'jquery'
  'b2'
  'game/entity/entity'
], ($, b2, Entity) ->

  BULLET_SPEED = 50
  BULLET_RADIUS = 0.05
  class Bullet extends Entity
    constructor: (@player, @pos, @dir, @bulletType) ->
      super(@player.game)

      @oldPosition = @body.GetWorldCenter().Copy()
      @currentPosition = @body.GetWorldCenter().Copy()

      # this gets called in the middle of world.Step()
      $(@body).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        if contact.IsTouching()
          @game.delegates.push( =>
            @destroy(this)
          )
          $(@body).off("begincontact")

          if @bulletType is "destroy"
            otherEntity = otherFixture.GetBody().GetUserData()
            @game.delegates.push( => otherEntity.destroy(this))
          else if @bulletType is "create"
            # blockCenter = @body.GetWorldCenter()
            wm = new b2.WorldManifold()
            contact.GetWorldManifold(wm)
            blockCenter = wm.m_points[0].Copy()
            @game.delegates.push(=>
              direction = wm.m_normal.Copy()
              direction.Multiply(0.5 - BULLET_RADIUS / 2)
              blockCenter.Add(direction)
              @game.createBlock(blockCenter.x, blockCenter.y)
            )

      )

      $(this).on("gotDestroyed", @unregister)
      $(this).on("destroyed", (evt, what) =>
        # use class type of @player instead of explicitly specifying Player to remove circular dependency
        return unless what instanceof @player.constructor
        @player.score += 1
      )

    makeBody: () =>
      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true
      bodyDef.position.SetV(@pos)

      bodyDef.linearVelocity.SetV(@dir)
      bodyDef.linearVelocity.Multiply(BULLET_SPEED)

      body = @game.world.CreateBody(bodyDef)

      fixDef = new b2.FixtureDef()
      fixDef.density = 0.0
      fixDef.friction = 0.0
      fixDef.restitution = 0
      fixDef.shape = new b2.CircleShape(BULLET_RADIUS)

      body.CreateFixture(fixDef)
      body

    isVisible: (player) => true

    prestep: () =>
      @body.ApplyForce(@game.world.GetGravity().GetNegative(), @body.GetWorldCenter())

    poststep: () =>
      @oldPosition = @currentPosition.Copy()
      @currentPosition = @body.GetWorldCenter().Copy()

    canSee: (player) => true

    draw: (renderer, defaultMethod) =>
      positionNow = @currentPosition
      renderer.cq.beginPath().strokeStyle(@color()).moveTo(@oldPosition.x, @oldPosition.y).lineTo(positionNow.x, positionNow.y).stroke()
      defaultMethod()

    color: () =>
      if(@bulletType is "create") then "green" else "red"

  return Bullet
