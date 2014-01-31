(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['jquery', 'underscore', 'b2', 'stats', 'utils', 'overlay', 'multi_contact_listener', 'mixin/registerable', 'game/entity/entity', 'game/entity/player', 'game/world/game_world'], function($, _, b2, Stats, Utils, Overlay, MultiContactListener, Registerable, Entity, Player, GameWorld) {
    var Game;
    Game = (function() {
      Utils.make(Game, Registerable("prestep", "poststep", "onstep"));

      function Game(width, height, playerNames, yourName, random) {
        var name, playerIndex;
        this.width = width;
        this.height = height;
        this.random = random;
        this.findEmptyAABB = __bind(this.findEmptyAABB, this);
        this.hashCode = __bind(this.hashCode, this);
        this.getWorldVertices = __bind(this.getWorldVertices, this);
        this.getBodiesInAABB = __bind(this.getBodiesInAABB, this);
        this.rayIntersect = __bind(this.rayIntersect, this);
        this.rayIntersectAll = __bind(this.rayIntersectAll, this);
        this.step = __bind(this.step, this);
        this.getFixturesOf = __bind(this.getFixturesOf, this);
        this.getBodies = __bind(this.getBodies, this);
        this.createBlock = __bind(this.createBlock, this);
        this.entities = [];
        this.world = new GameWorld(new b2.Vec2(0, 8), true, this);
        this.world.createMap();
        this.players = (function() {
          var _i, _len, _results;
          _results = [];
          for (playerIndex = _i = 0, _len = playerNames.length; _i < _len; playerIndex = ++_i) {
            name = playerNames[playerIndex];
            _results.push(new Player(name, this, playerIndex));
          }
          return _results;
        }).call(this);
        this.youPlayer = _.findWhere(this.players, {
          name: yourName
        });
        if (!this.youPlayer) {
          throw new Error("Couldn't find you!");
        }
        $(this.youPlayer).on("gotDestroyed", function(evt, bullet) {
          return Overlay.show("You got killed by " + bullet.player.name + "!");
        });
        this.finished = false;
      }

      Game.prototype.createBlock = function(x, y, isStatic) {
        if (isStatic == null) {
          isStatic = true;
        }
        return this.world.createBlock(x, y, isStatic);
      };

      Game.prototype.getBodies = function() {
        return Utils.nextArray(this.world.m_bodyList);
      };

      Game.prototype.getFixturesOf = function(body) {
        return Utils.nextArray(body.GetFixtureList());
      };

      Game.prototype.step = function() {
        $(this).trigger("prestep");
        this.world.Step(1 / 30, 8, 3);
        this.world.ClearForces();
        $(this).trigger("onstep");
        return $(this).trigger("poststep");
      };

      Game.prototype.rayIntersectAll = function(start, dir, filter, length) {
        var arr, offset, point2,
          _this = this;
        $(this).trigger('rayintersectall');
        arr = [];
        point2 = start.Copy();
        offset = dir.Copy();
        offset.Multiply(length);
        point2.Add(offset);
        this.world.RayCast(function(fixture, point, normal, fraction) {
          if (!(filter != null) || (typeof filter === "function" ? filter(fixture, point, normal, fraction) : void 0)) {
            arr.push({
              fixture: fixture,
              point: point.Copy(),
              normal: normal.Copy(),
              fraction: fraction
            });
          }
          return 1;
        }, start, point2);
        return arr;
      };

      Game.prototype.rayIntersect = function(start, dir, filter, length) {
        var arr,
          _this = this;
        arr = this.rayIntersectAll(start, dir, filter, length);
        if (arr.length > 0) {
          return _.min(arr, function(obj) {
            return obj.fraction;
          });
        } else {
          return void 0;
        }
      };

      Game.prototype.getBodiesInAABB = function(aabb) {
        var arr,
          _this = this;
        arr = [];
        this.world.QueryAABB((function(fixture) {
          return arr.push(fixture.GetBody());
        }), aabb);
        return arr;
      };

      Game.prototype.getWorldVertices = function(singlePolygonBody) {
        var fixture, shape, v, xf;
        xf = singlePolygonBody.m_xf;
        fixture = singlePolygonBody.GetFixtureList();
        shape = fixture.GetShape();
        return (function() {
          var _i, _len, _ref, _results;
          _ref = shape.GetVertices();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            v = _ref[_i];
            _results.push(b2.Math.MulX(xf, v));
          }
          return _results;
        })();
      };

      Game.prototype.hashCode = function() {
        var b, numbers;
        numbers = _.flatten([
          (function() {
            var _i, _len, _ref, _results;
            _ref = this.getBodies();
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              b = _ref[_i];
              _results.push([b.GetWorldCenter().x, b.GetWorldCenter().y]);
            }
            return _results;
          }).call(this)
        ]);
        return _.reduce(numbers, (function(accum, num) {
          return accum + num;
        }), 0);
      };

      Game.prototype.findEmptyAABB = function(rectWidth, rectHeight) {
        var aabb;
        aabb = new b2.AABB();
        while (true) {
          aabb.lowerBound.Set(this.random.float(-this.width / 2, this.width / 2), this.random.float(-this.height / 2, this.height / 2));
          aabb.upperBound.Set(aabb.lowerBound.x + rectWidth, aabb.lowerBound.y + rectHeight);
          if (_.isEmpty(this.getBodiesInAABB(aabb))) {
            break;
          }
        }
        return aabb;
      };

      return Game;

    })();
    return Game;
  });

}).call(this);
