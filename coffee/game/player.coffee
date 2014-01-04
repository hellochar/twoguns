define ['b2', 'utils'], (b2, Utils) ->

  class Player
    constructor: (@name, @game) ->
      @kills = 0

  return Player

