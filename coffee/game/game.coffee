define [
  'jquery',
  'underscore',
  'b2',
  'stats',
  'utils'
  'overlay'
  'multi_contact_listener',
  'mixin/registerable'
  'game/entity/entity'
  'game/entity/player'
  'game/world/game_world'
], ($, _, b2, Stats, Utils, Overlay, MultiContactListener, Registerable, Entity, Player, GameWorld) ->
  # model of the game
  #
  #   there is a physics world, with objects etc.
  #   there are players within the physics world
  #   there are bullets owned by players
  #   there is a win/lose condition

  class Game
    Utils.make(this, Registerable("prestep", "poststep", "onstep"))
    constructor: (@width, @height, playerNames, yourName, @random) ->
      @entities = []
      @world = new GameWorld(new b2.Vec2(0, 8), true, this)
      @world.createMap()

      @players = (new Player(name, this, playerIndex) for name, playerIndex in playerNames)
      @youPlayer = _.findWhere(@players, {name: yourName})
      throw new Error("Couldn't find you!") if not @youPlayer
      $(@youPlayer).on("gotDestroyed", (evt, bullet) ->
        Overlay.show("You got killed by #{bullet.player.name}!")
      )

    createBlock: (x, y, isStatic = true) =>
      @world.createBlock(x, y, isStatic)

    # returns an array of bodies
    getBodies: () =>
      Utils.nextArray(@world.m_bodyList)

    # returns an array of fixtures for the given Body
    getFixturesOf: (body) => Utils.nextArray(body.GetFixtureList())

    # delta = number of ms since the last call to step
    step: () =>
      $(@).trigger("prestep")

      @world.Step(1/30, 8, 3)
      @world.ClearForces()
      $(@).trigger("onstep")

      $(@).trigger("poststep")

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

    findEmptyAABB: (rectWidth, rectHeight) =>
      aabb = new b2.AABB()
      while true
        aabb.lowerBound.Set(@random.float(-@width/2, @width/2), @random.float(-@height/2, @height/2))
        aabb.upperBound.Set(aabb.lowerBound.x + rectWidth, aabb.lowerBound.y + rectHeight)

        break if _.isEmpty(@getBodiesInAABB(aabb))
      aabb



  return Game
