define [
], () ->
  class BlockUserData
    constructor: (@body) ->

    draw: (renderer, defaultMethod) =>
      defaultMethod()

    color: () => "rgba(0, 255, 0, .4)"

    image: () => "img/block.png"

  return BlockUserData
