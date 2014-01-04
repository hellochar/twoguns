define [
], () ->
  class PlayerUserData
    constructor: (@body) ->
      @player = @body.player
      @game = @player.game
    draw: (renderer, defaultMethod) =>
      defaultMethod()
    color: () => "rgb(255, 255, 0)"

  return PlayerUserData


