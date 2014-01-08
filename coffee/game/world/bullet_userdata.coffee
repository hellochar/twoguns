define [
], () ->
  class BulletUserData
    constructor: (@body) ->
      @oldPosition = @body.GetWorldCenter().Copy()
      @currentPosition = @body.GetWorldCenter().Copy()

    preStep: () ->

    postStep: () ->
      @oldPosition = @currentPosition.Copy()
      @currentPosition = @body.GetWorldCenter().Copy()

    draw: (renderer, defaultMethod) =>
      positionNow = @currentPosition
      renderer.cq.beginPath().stroke(@color()).moveTo(@oldPosition.x, @oldPosition.y).lineTo(positionNow.x, positionNow.y).stroke()
      defaultMethod()
    color: () => "green"

  return BulletUserData

