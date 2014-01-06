define [
], () ->
  class BlockUserData
    constructor: (@body) ->

    draw: (renderer, defaultMethod) =>
      defaultMethod() if @visible

    color: () => "green"

    image: () => "img/block.png"

  return BlockUserData
