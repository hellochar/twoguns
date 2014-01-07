define [
], () ->
  class BlockUserData
    constructor: (@body) ->

    draw: (renderer, defaultMethod) =>
      defaultMethod()

    color: () => "green"

    image: () => "img/block.png"

  return BlockUserData
