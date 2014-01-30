define [
  'underscore'
], (_) ->
  # An Entity is something that exists in the Game Model - this can be a Player, a Block, a Bullet, etc.
  # It has methods dealing with stepping
  # Most Entities will have a Box2D body associated with it, along with logic
  # to control that body.
  # Logic resides in prestep() and poststep(); in general:
  #
  #   use prestep() to apply forces and otherwise prepare your Entity for the next iteration
  #   use poststep() to recalculate values that may have changed because the physics has stepped
  #   use onstep() if your Entity doesn't belong in the physics world necessarily
  class Entity
    constructor: (@game) ->
      # this method serves the dual purpose of hooking up the game to this entity
      @game.entities.push(this)
      @game.register(this)
      @constructBody()

    constructBody: () =>
      @body = @makeBody() if @makeBody?
      @body.SetUserData(this)

    # by default, checks if this body blocked the line of sight
    # todo: maybe also check if this entity is in the visible poly?
    isVisible: (player) =>
      if @body
        _.contains(player.getCollidedBodies(), @body)
      else
        false

    # todo:
    #   phase out defaultMethod; implement it here
    #   set the renderer's transform, or at least provide lots of convenience methods
    draw: (renderer, defaultMethod) =>
      defaultMethod()

    # destroy this Entity's body; pass an optional (who) parameter to designate who destroyed it
    destroy: (who) =>
      @game.world.DestroyBody(@body)
      $(this).trigger("gotDestroyed", who)
      $(who).trigger("destroyed", this) if who
      delete @body

    # removes this entity from the game
    unregister: () =>
      @game.entities = _.without(@game.entities, this)
      @game.unregister(this)

  Entity
