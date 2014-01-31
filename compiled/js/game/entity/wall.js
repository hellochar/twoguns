(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['b2', 'game/entity/entity'], function(b2, Entity) {
    var Wall;
    return Wall = (function(_super) {
      __extends(Wall, _super);

      function Wall(game, center, hWidth, hHeight) {
        this.game = game;
        this.center = center;
        this.hWidth = hWidth;
        this.hHeight = hHeight;
        this.color = __bind(this.color, this);
        this.destroy = __bind(this.destroy, this);
        this.draw = __bind(this.draw, this);
        this.isVisible = __bind(this.isVisible, this);
        this.makeBody = __bind(this.makeBody, this);
        Wall.__super__.constructor.call(this, this.game);
      }

      Wall.prototype.makeBody = function() {
        var body, bodyDef, fixDef;
        bodyDef = new b2.BodyDef();
        bodyDef.type = b2.Body.b2_staticBody;
        fixDef = new b2.FixtureDef;
        fixDef.density = 1;
        fixDef.friction = 1;
        fixDef.restitution = 0;
        fixDef.shape = new b2.PolygonShape;
        fixDef.shape.SetAsBox(this.hWidth, this.hHeight);
        bodyDef.position.SetV(this.center);
        body = this.game.world.CreateBody(bodyDef);
        body.CreateFixture(fixDef);
        return body;
      };

      Wall.prototype.isVisible = function(player) {
        return true;
      };

      Wall.prototype.draw = function(renderer, defaultMethod) {
        return defaultMethod();
      };

      Wall.prototype.destroy = function(who) {};

      Wall.prototype.color = function() {
        return "black";
      };

      return Wall;

    })(Entity);
  });

}).call(this);
