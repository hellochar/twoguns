define [
  'underscore'
  'b2'
], (_, b2) ->

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

    toWorld: (renderer) =>
      c = @clone()
      c.mouse.location = renderer.worldVec2(new b2.Vec2(@mouse.x, @mouse.y))
      delete c.mouse.x
      delete c.mouse.y
      c


    serialize: () =>
      JSON.stringify(this)

    @unserialize: (string) =>
      {mouse: mouse, keys: keys} = JSON.parse(string)
      new Inputs(mouse, keys)

    pressed: (key) =>
      key of @keys

  return Inputs
