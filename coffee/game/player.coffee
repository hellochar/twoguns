define ['b2', 'utils'], (b2, Utils) ->

  class Player
    constructor: (@name, @game) ->
      @kills = 0
      @keysPressed = {} # key1: true, key2: true, key3: true
      @mouse = {
        location: new b2.Vec2()
        button : -1, # -1,0,1,2 === not-pressed, left, middle, right
      }


  return Player

