define ['jquery', 'box2d'], ($, Box2D) ->
  # Implements a contact listener that emits events in response to contact
  #
  # MultiContactListener triggers events for BeginContact and EndContact upon
  # the bodies and fixtures involved; this makes it easy to detect when certain
  # bodies are involved in contact events
  #
  # To listen for contact on a body, call $(body).on('begincontact', (evt, contact, myFixture, otherFixture) => ... )
  class MultiContactListener extends Box2D.Dynamics.b2ContactListener
    constructor: () ->

    triggerContactEvent: (eventName, contact) =>
      $(@world).trigger(eventName, contact)
      $(contact.GetFixtureA().GetBody()).trigger(eventName, [contact, contact.GetFixtureA(), contact.GetFixtureB()])
      $(contact.GetFixtureB().GetBody()).trigger(eventName, [contact, contact.GetFixtureB(), contact.GetFixtureA()])

      $(contact.GetFixtureA()).trigger(eventName, [contact, contact.GetFixtureA(), contact.GetFixtureB()])
      $(contact.GetFixtureB()).trigger(eventName, [contact, contact.GetFixtureB(), contact.GetFixtureA()])

    BeginContact: (contact) =>
      @triggerContactEvent("begincontact", contact)

    EndContact: (contact) =>
      @triggerContactEvent("endcontact", contact)

    # b2ContactListener exposes 4 methods: BeginContact, EndContact, PreSolve, PostSolve
    # haven't found a use for PreSolve or PostSolve yet
    PreSolve: (contact, oldManifold) =>

    PostSolve: (contact, impulse) =>

  MultiContactListener
