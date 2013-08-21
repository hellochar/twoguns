define ['jquery'], ($) ->
  class MultiContactListener extends Box2D.Dynamics.b2ContactListener
    constructor: (@world) ->
      world.SetContactListener(this)

    BeginContact: (contact) =>
      $(@world).trigger("begincontact", contact)
      $(contact.GetFixtureA().GetBody()).trigger("begincontact", [contact, contact.GetFixtureA(), contact.GetFixtureB()])
      $(contact.GetFixtureB().GetBody()).trigger("begincontact", [contact, contact.GetFixtureB(), contact.GetFixtureA()])

    EndContact: (contact) =>
      $(@world).trigger("endcontact", contact)

    PreSolve: (contact, oldManifold) =>
      $(@world).trigger("presolve", contact, oldManifold)

    PostSolve: (contact, impulse) =>
      $(@world).trigger("postsolve", contact, impulse)

  MultiContactListener
