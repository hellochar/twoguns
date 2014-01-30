define [
  'jquery'
  'underscore'
], ($, _) ->
  class Overlay
    @div: $("#overlay")
    
    @show: (text, time) =>
      @div.find(".text").text(text)
      @div.show()
      setTimeout(@hide, time) if time

    @hide: () =>
      @div.hide()
