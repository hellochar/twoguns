define [
  'b2'
  'utils'
  'game/player_body'
  'game/world/block_userdata'
], (b2, Utils, PlayerBody, BlockUserData) ->

  class Player
    constructor: (@name, @game) ->
      @kills = 0
      @createPlayerBody()

    createPlayerBody: () =>
      @playerBody = PlayerBody.create(@)

    update: () =>
      @keysPressed = @inputs.keys
      @mouse = @inputs.mouse
      IMPULSE_JUMP = new b2.Vec2(0, -0.04 / @playerBody.GetMass())
      FORCE_WALK_X = 4.0
      FORCE_FLY = new b2.Vec2(0, -0.8)
      loc = @playerBody.GetWorldCenter().Copy()

      if @inputs.pressed('w') and @playerBody.canJump()
        @playerBody.ApplyImpulse(IMPULSE_JUMP, loc)

      if @inputs.pressed('w')
        @playerBody.ApplyForce(FORCE_FLY, loc)

      vel = @playerBody.GetLinearVelocity()

      if @inputs.pressed('a')
        @playerBody.SetLinearVelocity(new b2.Vec2(-FORCE_WALK_X, vel.y))
      else if @inputs.pressed('d')
        @playerBody.SetLinearVelocity(new b2.Vec2(FORCE_WALK_X, vel.y))
      else
        @playerBody.SetLinearVelocity(new b2.Vec2(0, vel.y))

      if @inputs.pressed('s')
        @playerBody.ApplyImpulse(new b2.Vec2(0, IMPULSE_JUMP / 10), loc)

      if @mouse.down
        @playerBody.shootAt(@mouse.location, {0: "create", 2: "destroy"}[@mouse.button])

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

    getVisionPoly: () =>
      @playerBody.getVisionPoly()

    # this method should make the renderer look at you, offset by the mouse position
    lookAt: (renderer, mx, my) =>
      # these two methods MUST go together for it to work; kinda janky
      renderer.lookAt(@playerBody.GetPosition())
      renderer.center.SetV(renderer.worldVec2(new b2.Vec2(mx, my)))




  return Player

