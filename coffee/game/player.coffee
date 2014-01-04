define [
  'b2'
  'utils'
  'game/player_body'
  'game/world/block_userdata'
], (b2, Utils, PlayerBody, BlockUserData) ->

  class Player
    constructor: (@name, @game) ->
      @kills = 0
      @keysPressed = {} # key1: true, key2: true, key3: true
      @mouse = {
        location: new b2.Vec2()
        button : -1, # -1,0,1,2 === not-pressed, left, middle, right
      }
      @createPlayerBody()

    createPlayerBody: () =>
      @playerBody = PlayerBody.create(@)

    update: () =>
      IMPULSE_JUMP = new b2.Vec2(0, -0.04 / @playerBody.GetMass())
      FORCE_WALK_X = 4.0
      FORCE_FLY = new b2.Vec2(0, -0.8)
      loc = @playerBody.GetWorldCenter().Copy()

      if 'w' of @keysPressed and @playerBody.canJump()
        @playerBody.ApplyImpulse(IMPULSE_JUMP, loc)

      if 'w' of @keysPressed
        @playerBody.ApplyForce(FORCE_FLY, loc)

      vel = @playerBody.GetLinearVelocity()

      if 'a' of @keysPressed
        @playerBody.SetLinearVelocity(new b2.Vec2(-FORCE_WALK_X, vel.y))
      else if 'd' of @keysPressed
        @playerBody.SetLinearVelocity(new b2.Vec2(FORCE_WALK_X, vel.y))
      else
        @playerBody.SetLinearVelocity(new b2.Vec2(0, vel.y))

      if 's' of @keysPressed
        @playerBody.ApplyImpulse(new b2.Vec2(0, IMPULSE_JUMP / 10), loc)

      # hack: should be moved into bullet class
      bullet.ApplyForce(@playerBody.world.GetGravity().GetNegative(), bullet.GetWorldCenter()) for bullet in @playerBody.bullets

      direction = @playerBody.directionTo(@mouse.location)
      sightline = ( =>
        isect = @playerBody.game.rayIntersect(@playerBody.GetWorldCenter(), direction,
          (fixture) -> fixture.GetBody().GetUserData() instanceof BlockUserData
        )
        if isect
          return (cq) =>
            cq.fillStyle("red").beginPath().circle(isect.point.x, isect.point.y, 0.035).fill()
            cq.strokeStyle("red").beginPath().
              moveTo(@playerBody.GetWorldCenter().x, @playerBody.GetWorldCenter().y).
              lineTo(isect.point.x, isect.point.y).
              stroke()
        else
          undefined
      )()
      @game.particles.push(sightline) if sightline
      @playerBody.calculateVisionPoly()

    shootAt: () =>
      @playerBody.shootAt.apply(@playerBody, arguments)

    getVisionPoly: () =>
      @playerBody.getVisionPoly()

    lookAt: (renderer, mouse) =>
      renderer.lookAt(@playerBody.GetPosition())
      renderer.center.SetV(renderer.worldVec2(new b2.Vec2(mouse.x, mouse.y)))




  return Player

