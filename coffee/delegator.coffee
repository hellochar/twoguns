define [
], () ->
  # automatically stubs
  class Delegator
    constructor: (@_methods) ->
      for name in @_methods
        @[name] = (() =>
          if @forwardedTo[name]
            @forwardedTo[name].apply(@forwardedTo, arguments)
          else
            undefined #stub a no-op
        )

    forward: (who) =>
      @forwardedTo = who

  return Delegator
