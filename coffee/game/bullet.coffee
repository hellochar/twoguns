define [
  'jquery'
  'b2'
  'game/world/block_userdata'
  'game/world/bullet_userdata'
], ($, b2, BlockUserData, BulletUserData) ->
  class Bullet
    constructor: (@player, pos, dir, @bulletType) ->
      @game = @player.game
      @game.register(this)
      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_dynamicBody
      bodyDef.bullet = true
      bodyDef.position.SetV(pos)

      BULLET_SPEED = 50
      bodyDef.linearVelocity.SetV(dir)
      bodyDef.linearVelocity.Multiply(BULLET_SPEED)

      @body = @game.world.CreateBody(bodyDef)
      @body.SetUserData(new BulletUserData(@body, this))

      fixDef = new b2.FixtureDef()
      fixDef.density = 0.0
      fixDef.friction = 0.0
      fixDef.restitution = 0
      # fixDef.isSensor = true
      fixDef.shape = new b2.CircleShape(.05)

      @body.CreateFixture(fixDef)

      $(@body).on("begincontact", (evt, contact, myFixture, otherFixture) =>
        if contact.IsTouching()
          @game.delegates.push( =>
            @game.world.DestroyBody(@body)
          )
          $(@body).off("begincontact")

          if @bulletType is "destroy"
            @game.delegates.push(=>@game.world.DestroyBody(otherFixture.GetBody()))
          else if @bulletType is "create"
            @game.delegates.push(=>
              blockCenter = @body.GetWorldCenter()
              direction = contact.GetManifold().m_localPoint
              length = direction.Normalize()
              direction.Multiply(length - fixDef.shape.GetRadius())
              blockCenter.Add(direction)
              @game.createBlock(blockCenter.x, blockCenter.y)
            )

      )

    prestep: () =>
      @body.ApplyForce(@game.world.GetGravity().GetNegative(), @body.GetWorldCenter())


  return Bullet
