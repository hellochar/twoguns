define [
  'b2'
  'game/entity/entity'
], (b2, Entity) ->
  class Wall extends Entity
    constructor: (@game, @center, @hWidth, @hHeight) ->
      super(@game)

    makeBody: () =>
      bodyDef = new b2.BodyDef()
      bodyDef.type = b2.Body.b2_staticBody
      fixDef = new b2.FixtureDef
      fixDef.density = 1
      fixDef.friction = 1
      fixDef.restitution = 0
      fixDef.shape = new b2.PolygonShape
      fixDef.shape.SetAsBox(@hWidth, @hHeight)
      bodyDef.position.SetV(@center)
      body = @game.world.CreateBody(bodyDef)
      body.CreateFixture(fixDef)
      body

    isVisible: (player) => true

    draw: (renderer, defaultMethod) =>
      defaultMethod()

    # no-op for destroy
    destroy: (who) =>

    color: () => "black"
