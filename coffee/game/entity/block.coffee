define [
  'b2'
  'settings'
  'game/entity/entity'
], (b2, settings, Entity) ->
  class Block extends Entity
    @SIZE = settings.block.size
    @isStatic = settings.block.isStatic
    constructor: (@game, @center, @size = @constructor.SIZE, @static = @constructor.isStatic) ->
      super(@game)

    makeBody: () =>
      bodyDef = new b2.BodyDef()
      bodyDef.type = if @static then b2.Body.b2_staticBody else b2.Body.b2_dynamicBody
      bodyDef.position.SetV(@center)

      fixDef = new b2.FixtureDef
      fixDef.density = 1
      fixDef.friction = settings.block.friction
      fixDef.restitution = 0
      fixDef.shape = new b2.PolygonShape
      fixDef.shape.SetAsBox(@size/2, @size/2)
      body = @game.world.CreateBody(bodyDef)
      body.CreateFixture(fixDef)
      body

    isVisible: (player) =>
      true

    draw: (renderer, defaultMethod) =>
      super(renderer, defaultMethod)

    color: () => "rgba(0, 255, 0, .4)"

    image: () => "img/block.png"


  return Block
