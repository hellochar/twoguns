define [
], () ->
  class BlockUserData
    constructor: (@body) ->

    draw: (defaultMethod) =>
      defaultMethod() if @visible

    color: () => "green"

  return BlockUserData
