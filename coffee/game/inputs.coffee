define [
  'underscore'
], (_) ->

  class Inputs
    constructor: (@mouse, @keys) ->
      @mouse ||= {}
      @keys ||= {}
      _.defaults(@mouse,
        x : 0
        y : 0
        button : -1 # -1,0,1,2 === not-pressed, left, middle, right
        down: false
      )
      _.defaults(@keys, {})

    clone: () => new Inputs(_.clone(@mouse), _.clone(@keys))

    setLocation: (x, y) =>
      @mouse.x = x
      @mouse.y = y

    mousedown: (x, y, button) =>
      @setLocation(x, y)
      @mouse.button = button
      @mouse.down = true

    mouseup: (x, y, button) =>
      @setLocation(x, y)
      @mouse.button = -1
      @mouse.down = false

    pressed: (key) =>
      key of @keys

  return Inputs
