define [
  'jquery'
], (
  $,

) ->
  class Scoreboard
    constructor: (@game) ->
      @game.register(this)
      @el = $("<div>")
        .css(
          position: "absolute"
          top: "0px"
          right: "0px"
          color: "white"
        )
        .appendTo("body")

    poststep: () =>
      @el.empty()
      for player in _.sortBy(@game.players, (player) -> -1 * player.score)
        row = $("<div>").text("#{player.name} - #{player.score}").appendTo(@el)
        if player is @game.youPlayer
          row.css("background-color", "black")

  Scoreboard
