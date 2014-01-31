(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['b2', 'game/entity/entity'], function(b2, Entity) {
    var Block;
    Block = (function(_super) {
      __extends(Block, _super);

      function Block(game, center, size, _static) {
        this.game = game;
        this.center = center;
        this.size = size;
        this["static"] = _static;
        this.image = __bind(this.image, this);
        this.color = __bind(this.color, this);
        this.draw = __bind(this.draw, this);
        this.isVisible = __bind(this.isVisible, this);
        this.makeBody = __bind(this.makeBody, this);
        Block.__super__.constructor.call(this, this.game);
      }

      Block.prototype.makeBody = function() {
        var body, bodyDef, fixDef;
        bodyDef = new b2.BodyDef();
        bodyDef.type = this["static"] ? b2.Body.b2_staticBody : b2.Body.b2_dynamicBody;
        bodyDef.position.SetV(this.center);
        fixDef = new b2.FixtureDef;
        fixDef.density = 1;
        fixDef.friction = 1;
        fixDef.restitution = 0;
        fixDef.shape = new b2.PolygonShape;
        fixDef.shape.SetAsBox(this.size / 2, this.size / 2);
        body = this.game.world.CreateBody(bodyDef);
        body.CreateFixture(fixDef);
        return body;
      };

      Block.prototype.isVisible = function(player) {
        return true;
      };

      Block.prototype.draw = function(renderer, defaultMethod) {
        return Block.__super__.draw.call(this, renderer, defaultMethod);
      };

      Block.prototype.color = function() {
        return "rgba(0, 255, 0, .4)";
      };

      Block.prototype.image = function() {
        return "img/block.png";
      };

      return Block;

    })(Entity);
    return Block;
  });

}).call(this);
