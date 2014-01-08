define [
  'game/inputs'
], (Inputs) ->
  class InputRecorder
    constructor: () ->
      @inputs = []

    record: (input) =>
      @inputs.push(input.clone())

    serialize: () =>
      JSON.stringify(@inputs)

  return InputRecorder
