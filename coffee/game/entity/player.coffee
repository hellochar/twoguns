define [
  'b2'
  'utils'
  'game/entity/entity'
  'game/entity/bullet'
  'game/entity/player_body'
  'game/world/block_userdata'
], (b2, Utils, Entity, Bullet, PlayerBody, BlockUserData) -> 

  class Player extends Entity
    constructor: (@name, @game) ->
      super(@game)
      @bullet_sound = new Audio()
      @bullet_sound.src = "gun-gunshot-02.mp3"
      @bullet_sound.volume = .2
      # normalized vector representing the angle you are looking at
      @direction = new b2.Vec2(1, 0)



    makeBody: () => PlayerBody.create(@)

    prestep: () =>
      @mouse = @inputs.mouse
      IMPULSE_JUMP = new b2.Vec2(0, -0.04 / @body.GetMass())
      IMPULSE_DOWN = new b2.Vec2(0, -0.04 / @body.GetMass())
      FORCE_WALK_X = 4.0
      FORCE_FLY = new b2.Vec2(0, -0.8)
      loc = @body.GetWorldCenter().Copy()

      if @inputs.pressed('w') and @body.canJump()
        @body.ApplyImpulse(IMPULSE_JUMP, loc)

      if @inputs.pressed('w')
        @body.ApplyForce(FORCE_FLY, loc)

      vel = @body.GetLinearVelocity()

      if @inputs.pressed('a')
        @body.SetLinearVelocity(new b2.Vec2(-FORCE_WALK_X, vel.y))
      else if @inputs.pressed('d')
        @body.SetLinearVelocity(new b2.Vec2(FORCE_WALK_X, vel.y))
      else
        @body.SetLinearVelocity(new b2.Vec2(0, vel.y))

      if @inputs.pressed('s')
        @body.ApplyImpulse(IMPULSE_JUMP.Copy().Multiply(1/10), loc)

      if @mouse.down
        @shoot({0: "destroy", 2: "create"}[@mouse.button])

    poststep: () =>
      @direction = @directionTo(@mouse.location)

      delete @body.visionPoly
      delete @body.collidedBodies

    directionTo: (x, y) =>
      if "x" of x and "y" of x and y == undefined
        {x: x, y: y} = x

      direction = new b2.Vec2(x, y)
      direction.Subtract(@body.GetWorldCenter())
      direction.Normalize()

      direction

    getCollidedBodies: () =>
      @getVisionPoly()
      @body.collidedBodies

    getVisionPoly: () =>
      @body.getVisionPoly()

    # you can see yourself
    # if it's a block, you can see it
    # if it's a body blocking your line of sight, you can see it
    # if it's a bullet, you can see it
    canSee: (body) =>
      return true if body is @body
      return true if body.GetUserData() instanceof BlockUserData
      return true if _.contains(@getCollidedBodies(), body)
      return true if body.GetUserData() instanceof Bullet

    shoot: (bulletType) =>
      @bullet_sound.currentTime = 0
      @bullet_sound.play()

      pos = @body.GetWorldCenter().Copy()
      positionOffset = @direction.Copy()
      DISTANCE_OFFSET = .5
      positionOffset.Multiply(DISTANCE_OFFSET)
      pos.Add(positionOffset)

      new Bullet(@, pos, @direction, bulletType)

    # this method should make the renderer look at you, offset by the mouse position
    lookAt: (renderer, mx, my) =>
      # these two methods MUST go together for it to work; kinda janky
      renderer.lookAt(@body.GetPosition())
      renderer.center.SetV(renderer.worldVec2(new b2.Vec2(mx, my)))

    draw: (renderer, defaultMethod) =>
      defaultMethod()
      # draw a head on top
      cq = renderer.cq
      cq.save().translate(@body.GetWorldCenter().x, @body.GetWorldCenter().y)
        .translate(0, -0.4).rotate(Math.atan2(@direction.y, @direction.x) + Math.PI / 2)
        .fillStyle(@color()).strokeStyle("red")
        .beginPath()
        .moveTo(-0.1, 0)
        .lineTo(+0.1, 0)
        .lineTo(0, -.28)
        .closePath()
        .stroke().fill()
        .restore()
    color: () => "rgb(255, 255, 0)"




  return Player

