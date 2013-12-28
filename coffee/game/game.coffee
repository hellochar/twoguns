define [
  'jquery',
  'underscore',
  'b2',
  'stats',
  'multi_contact_listener',
  'game/random',
  'game/player_body'
  'game/world/game_world'
], ($, _, b2, Stats, MultiContactListener, Random, PlayerBody, GameWorld) ->
  # model of the game
  #
  #   there is a physics world, with objects etc.
  #   there are players within the physics world
  #   there are bullets owned by players
  #   there is a win/lose condition

  class Game
    BLOCK_BODYDEF = new b2.BodyDef
    BLOCK_BODYDEF.type = b2.Body.b2_staticBody

    BLOCK_FIXDEF = new b2.FixtureDef
    BLOCK_FIXDEF.density = 1
    BLOCK_FIXDEF.friction = 1
    BLOCK_FIXDEF.restitution = 0
    BLOCK_FIXDEF.shape = new b2.PolygonShape

    constructor: (@width, @height, @gridSize, @random = new Random()) ->
      @world = new GameWorld(new b2.Vec2(0, 8), true, this)

      # create you
      @you = PlayerBody.create(@)

      # callbacks to be invoked right before the game steps
      # Use this to e.g. add and remove blocks that you can't do during
      # a callback function for collisions
      @delegates = []

      # particles are methods that get the rendering context passed to them so they can draw; they're also cleared at every time step
      @particles = []

    createBlock: (x, y, isStatic = true) =>
      @world.createBlock(x, y, isStatic)

    # keysPressed = char (as a string) -> true
    # mouse = {location, button}
    # delta = number of ms since the last call to step
    step: (keysPressed, mouse, delta) =>
      @particles = []

      @you.update(keysPressed, mouse)

      method() for method in @delegates
      @delegates = []
      @world.Step(delta / 1000, 10, 10)
      @world.ClearForces()

    mouseDown: (location, button) =>
      @you.shootAt(location, {0: "create", 2: "destroy"}[button])

    rayIntersectAll: (start, dir, filter, length = 10000) =>
      arr = []
      point2 = start.Copy()
      offset = dir.Copy()
      offset.Multiply(length)
      point2.Add(offset)

      @world.RayCast((fixture, point, normal, fraction) =>
        if !(filter?) or filter?(fixture, point, normal, fraction)
          arr.push(
            fixture: fixture
            point: point
            normal: normal
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
    rayIntersect: (start, dir, filter, length = 10000) =>
      arr = @rayIntersectAll(start, dir, filter)

      if arr.length > 0
        _.min(arr, (obj) =>
          offset = obj.point.Copy()
          offset.Subtract(start)
          offset.LengthSquared()
        )
      else
        undefined


  return Game
