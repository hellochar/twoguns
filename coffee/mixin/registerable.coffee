define [
  'underscore'
], (_) ->
  Registerable = (eventNames...) -> {
    register: (listener) ->
      $(@).on(name, listener[name]) for name in eventNames when listener[name]?
  }
