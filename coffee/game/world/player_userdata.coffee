define [
], () ->
  class PlayerUserData
    constructor: (@body) ->
      @player = @body.player
      @game = @player.game
    draw: (renderer, defaultMethod) =>
      defaultMethod()
      # draw a head on top
      cq = renderer.cq
      cq.save().translate(@body.GetWorldCenter().x, @body.GetWorldCenter().y)
        .translate(0, -0.4).rotate(Math.atan2(@body.direction.y, @body.direction.x) + Math.PI / 2)
        .fillStyle(@color()).strokeStyle("red")
        .beginPath()
        .moveTo(-0.1, 0)
        .lineTo(+0.1, 0)
        .lineTo(0, -.28)
        .closePath()
        .stroke().fill()
        .restore()
    color: () => "rgb(255, 255, 0)"

  return PlayerUserData


