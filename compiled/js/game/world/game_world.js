(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'b2', 'multi_contact_listener', 'game/entity/wall', 'game/entity/block'], function($, b2, MultiContactListener, Wall, Block) {
    var BLOCK_BODYDEF, BLOCK_FIXDEF, GameWorld;
    BLOCK_BODYDEF = new b2.BodyDef;
    BLOCK_BODYDEF.type = b2.Body.b2_staticBody;
    BLOCK_FIXDEF = new b2.FixtureDef;
    BLOCK_FIXDEF.density = 1;
    BLOCK_FIXDEF.friction = 1;
    BLOCK_FIXDEF.restitution = 0;
    BLOCK_FIXDEF.shape = new b2.PolygonShape;
    GameWorld = (function(_super) {
      __extends(GameWorld, _super);

      function GameWorld(gravity, allowSleep, game) {
        this.game = game;
        this.createBoundingBoxes = __bind(this.createBoundingBoxes, this);
        this.createBlock = __bind(this.createBlock, this);
        this.generateNoiseBoxes = __bind(this.generateNoiseBoxes, this);
        this.createMap = __bind(this.createMap, this);
        GameWorld.__super__.constructor.call(this, gravity, allowSleep);
        this.b2World.apply(this, [gravity, allowSleep]);
        this.SetContactListener(new MultiContactListener());
      }

      GameWorld.prototype.createMap = function() {
        this.createBoundingBoxes(this.game.width, this.game.height);
        return this.generateNoiseBoxes(3, 1);
      };

      GameWorld.prototype.generateNoiseBoxes = function(noiseScalar, gridSize) {
        var x, y, _i, _ref, _ref1, _results;
        BLOCK_FIXDEF.shape.SetAsBox(gridSize / 2, gridSize / 2);
        _results = [];
        for (x = _i = _ref = -this.game.width / 2, _ref1 = this.game.width / 2; gridSize > 0 ? _i < _ref1 : _i > _ref1; x = _i += gridSize) {
          _results.push((function() {
            var _j, _ref2, _ref3, _results1;
            _results1 = [];
            for (y = _j = _ref2 = -this.game.height / 2, _ref3 = this.game.height / 2; gridSize > 0 ? _j < _ref3 : _j > _ref3; y = _j += gridSize) {
              if ((this.game.random.perlin(x / noiseScalar, y / noiseScalar, 0) + 1) / 2 < .5) {
                _results1.push(this.createBlock(x + gridSize / 2, y + gridSize / 2));
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      GameWorld.prototype.createBlock = function(x, y, isStatic) {
        if (isStatic == null) {
          isStatic = true;
        }
        return new Block(this.game, new b2.Vec2(x, y), 1, isStatic);
      };

      GameWorld.prototype.createBoundingBoxes = function(width, height) {
        new Wall(this.game, new b2.Vec2(0, -(height / 2 + 1)), width / 2 + 1 / 2, 1);
        new Wall(this.game, new b2.Vec2(0, +(height / 2 + 1)), width / 2 + 1 / 2, 1);
        new Wall(this.game, new b2.Vec2(-(width / 2 + 1), 0), 1, height / 2 + 1 / 2);
        return new Wall(this.game, new b2.Vec2(+(width / 2 + 1), 0), 1, height / 2 + 1 / 2);
      };

      return GameWorld;

    })(b2.World);
    return GameWorld;
  });

}).call(this);
