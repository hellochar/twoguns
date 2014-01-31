define [
  'jquery'
  'underscore'
], ($, _) ->
  class Overlay
    @div: $("#overlay")

    @show: (text, fadeTime) =>
      @text(text)
      # @div.show()
      @div.fadeIn(fadeTime || 100)

    @text: (text) =>
      @div.find(".text").text(text)

    @hide: (fadeTime) =>
      @div.fadeOut(fadeTime || 100)
