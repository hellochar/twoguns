define [
  'game/inputs'
], (Inputs) ->
  class InputPlayback
    constructor: (serializedInput) ->
      @inputs = JSON.parse(serializedInput)
      @mark = 0

    next: () =>
      next = @inputs[@mark]
      @mark = (@mark + 1) % @inputs.length
      next

  return InputPlayback

