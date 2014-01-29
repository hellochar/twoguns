define [
  'underscore'
], (_) ->
  # pass names of events that will fire on yourself you want to expose to others
  # exposes a register(listener) method that adds the listener to listen to the given events and
  # automatically call a method with the same name on the listener
  #
  # Use mixins with Utils.make(klass, mixin) to give klass' prototype the mixin's methods
  #
  #
  Registerable = (eventNames...) -> {
    register: (listener) ->
      $(@).on(name, listener[name]) for name in eventNames when listener[name]?
    unregister: (listener) ->
      $(@).off(name, listener[name]) for name in eventNames when listener[name]?
  }
