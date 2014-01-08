define [
], () ->
  class BulletUserData
    constructor: (@body, @bullet) ->
      @oldPosition = @body.GetWorldCenter().Copy()
      @currentPosition = @body.GetWorldCenter().Copy()
      @body.GetWorld().game.register(this)

    prestep: () =>

    poststep: () =>
      @oldPosition = @currentPosition.Copy()
      @currentPosition = @body.GetWorldCenter().Copy()

    draw: (renderer, defaultMethod) =>
      positionNow = @currentPosition
      renderer.cq.beginPath().strokeStyle(@color()).moveTo(@oldPosition.x, @oldPosition.y).lineTo(positionNow.x, positionNow.y).stroke()
      defaultMethod()

    color: () =>
      if(@bullet.bulletType is "create") then "green" else "red"

  return BulletUserData

