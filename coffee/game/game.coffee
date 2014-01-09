define [
  'jquery',
  'underscore',
  'b2',
  'stats',
  'utils'
  'multi_contact_listener',
  'game/player'
  'game/random',
  'game/player_body'
  'game/world/game_world'
], ($, _, b2, Stats, Utils, MultiContactListener, Player, Random, PlayerBody, GameWorld) ->
  # model of the game
  #
  #   there is a physics world, with objects etc.
  #   there are players within the physics world
  #   there are bullets owned by players
  #   there is a win/lose condition

  class Game
    constructor: (@width, @height, playerNames, yourName, @random = new Random()) ->
      @entities = []
      @world = new GameWorld(new b2.Vec2(0, 8), true, this)

      @players = (new Player(name, this) for name in playerNames)
      @youPlayer = ( =>
        yourIndex = playerNames.indexOf(yourName)
        @players[yourIndex]
      )()

      # callbacks to be invoked right before the game steps
      # Use this to e.g. add and remove blocks that you can't do during
      # a callback function for collisions
      @delegates = []

    # examples:
    #   g = new Game()
    #   g.create(Player, "hellochar")
    #
    #
    #   Game:
    #     constructor: () =>
    #       @world = new b2.World()
    #
    #     create: (entity, args...) =>
    #       inst = new entity(args..., this)
    #       @entities.push(inst)
    #
    #     step:
    #       @entities.preStep()
    #       
    #       # game step involves:
    #       # stepping the physics
    #       # resolving all callbacks
    #       @world.TimeStep(1/60f)
    #       @entities.postStep()
    #
    #
    #   Entity:
    #     constructor: (@game) ->
    #       @body = @createBody()
    #
    #     # the only invariant of preStep is that it will be called exactly once on each Entity in the game
    #     # before TimeStep
    #     # use to enforce invariants about what your characters will do
    #     preStep()
    #     # called exactly once on each Entity in the game after TimeStep
    #     # use to enforce invariants about your variables; update them to reflect the new state of the game
    #     postStep()
    #
    #   Player extends Entity:
    #
    #     BODYDEF = {}
    #
    #     constructor (@name, game):
    #       super(game)
    #
    #     createBody: () =>
    #       body = @game.world.CreateBody(BODYDEF)
    #       body.feet = body.CreateFixture(FEET)
    #       body.torso = body.CreateFixture(TORSO)
    #       body
    #
    #     preStep: () =>
    #       if keysPressed('w')
    #         body.ApplyForce()...
    #       ...
    #       ...
    #
    #     postStep: () =>
    #       @calculateVisionPoly()
    #
    #     shoot:
    #       @game.create(Bullet, this, DESTROY)
    #
    #
    #
    #
    #   vs.
    #
    #   g.addEntity(new Player("hellochar"))
    #
    #   addEntity: (ent) =>
    #     @entities.push(ent)
    #     $(ent).trigger("added", this)
    #
    #   Player extends Entity:
    #     constructor: (@name) ->
    #       super()
    #       $(this).on("added", (game) =>
    #         @game = game
    #
    #
    #
    # create: (entity, args...) =>
    #   args.push(
    #   @entities.push(new entity(

    createBlock: (x, y, isStatic = true) =>
      @world.createBlock(x, y, isStatic)

    # returns an array of bodies
    getBodies: () =>
      Utils.nextArray(@world.m_bodyList)

    # returns an array of fixtures for the given Body
    getFixturesOf: (body) => Utils.nextArray(body.GetFixtureList())

    # delta = number of ms since the last call to step
    step: () =>
      method() for method in @delegates
      @delegates = []

      $(@).trigger("prestep")

      @world.Step(1/30, 10, 10)
      @world.ClearForces()
      $(@).trigger("onstep")

      $(@).trigger("poststep")

    register: (listener) =>
      eventNames = ["prestep", "poststep"]
      $(@).on(name, listener[name]) for name in eventNames when listener[name]?

    rayIntersectAll: (start, dir, filter, length) =>
      $(@).trigger('rayintersectall')
      arr = []
      point2 = start.Copy()
      offset = dir.Copy()
      offset.Multiply(length)
      point2.Add(offset)

      @world.RayCast((fixture, point, normal, fraction) =>
        if !(filter?) or filter?(fixture, point, normal, fraction)
          arr.push(
            fixture: fixture
            point: point.Copy()
            normal: normal.Copy()
            fraction: fraction
          )
        # RayCast will keep going or stop depending on the return value; 1 means keep going
        return 1
      , start, point2)

      arr

    # returns a {fixture: b2Fixture, point: b2Vec2, normal: b2Vec2, fraction: Number}
    # representing the first hit of this ray
    #
    # start: start vec2 of the ray
    # dir: normalized direction of the ray
    # filter: function (fixture, point, normal, fraction) => boolean;
    #   only look at intersections that match this filter
    rayIntersect: (start, dir, filter, length) =>
      arr = @rayIntersectAll(start, dir, filter, length)

      if arr.length > 0
        #minimum by distance to start
        _.min(arr, (obj) => obj.fraction)
      else
        undefined

    getBodiesInAABB: (aabb) =>
      arr = []
      @world.QueryAABB(((fixture) => arr.push(fixture.GetBody())), aabb)
      return arr

    getWorldVertices: (singlePolygonBody) =>
      xf = singlePolygonBody.m_xf
      fixture = singlePolygonBody.GetFixtureList()
      shape = fixture.GetShape()
      return (b2.Math.MulX(xf, v) for v in shape.GetVertices())

    hashCode: () =>
      numbers = _.flatten([[b.GetWorldCenter().x, b.GetWorldCenter().y] for b in @getBodies()])
      _.reduce(numbers, ((accum, num) -> accum + num), 0)


  return Game
