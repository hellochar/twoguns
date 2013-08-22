define ['jquery', 'box2d'], ($, Box2D) ->
  class MultiContactListener extends Box2D.Dynamics.b2ContactListener
    constructor: (@world) ->
      world.SetContactListener(this)

      for box2dName in ["BeginContact", "EndContact"]
        eventName = box2dName.toLowerCase()
        do (eventName) =>
          this[box2dName] = (contact) =>
            $(@world).trigger(eventName, contact)
            $(contact.GetFixtureA().GetBody()).trigger(eventName, [contact, contact.GetFixtureA(), contact.GetFixtureB()])
            $(contact.GetFixtureB().GetBody()).trigger(eventName, [contact, contact.GetFixtureB(), contact.GetFixtureA()])

            $(contact.GetFixtureA()).trigger(eventName, [contact, contact.GetFixtureA(), contact.GetFixtureB()])
            $(contact.GetFixtureB()).trigger(eventName, [contact, contact.GetFixtureB(), contact.GetFixtureA()])

    PreSolve: (contact, oldManifold) =>
      $(@world).trigger("presolve", contact, oldManifold)

    PostSolve: (contact, impulse) =>
      $(@world).trigger("postsolve", contact, impulse)

  MultiContactListener
