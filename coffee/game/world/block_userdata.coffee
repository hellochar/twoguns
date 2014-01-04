define [
], () ->
  class BlockUserData
    constructor: (@body) ->

    draw: (renderer, defaultMethod) =>
      defaultMethod() if @visible

    color: () => "green"

  return BlockUserData
