define [
], () ->
  class BlockUserData
    constructor: (@body) ->

    draw: (defaultMethod) =>
      game = @body.GetWorld().game
      you = game.you

      points = game.getWorldVertices(@body)


      visible = _.some(points, (p1) =>
        p2 = you.GetWorldCenter().Copy()
        p2.Subtract(p1)
        isect = game.rayIntersect(p1, p2, null, 1)
        isect?.fixture?.GetBody() is you
      )
      defaultMethod() if visible

    color: () => "green"

  return BlockUserData
