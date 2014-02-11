(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'b2', 'settings', 'game/entity/block', 'game/entity/entity'], function($, b2, settings, Block, Entity) {
    var Bullet;
    Bullet = (function(_super) {
      __extends(Bullet, _super);

      Bullet.BULLET_SPEED = settings.bullet.speed;

      Bullet.BULLET_RADIUS = settings.bullet.radius;

      function Bullet(player, pos, dir, bulletType) {
        var _this = this;
        this.player = player;
        this.pos = pos;
        this.dir = dir;
        this.bulletType = bulletType;
        this.color = __bind(this.color, this);
        this.draw = __bind(this.draw, this);
        this.canSee = __bind(this.canSee, this);
        this.poststep = __bind(this.poststep, this);
        this.prestep = __bind(this.prestep, this);
        this.isVisible = __bind(this.isVisible, this);
        this.makeBody = __bind(this.makeBody, this);
        Bullet.__super__.constructor.call(this, this.player.game);
        this.oldPosition = this.body.GetWorldCenter().Copy();
        this.currentPosition = this.body.GetWorldCenter().Copy();
        $(this.body).on("begincontact", function(evt, contact, myFixture, otherFixture) {
          var blockCenter, otherEntity, wm;
          if (contact.IsTouching()) {
            $(_this.game).one("poststep", function() {
              return _this.destroy(_this);
            });
            $(_this.body).off("begincontact");
            if (_this.bulletType === "destroy") {
              otherEntity = otherFixture.GetBody().GetUserData();
              return $(_this.game).one("poststep", function() {
                return otherEntity.destroy(_this);
              });
            } else if (_this.bulletType === "create") {
              wm = new b2.WorldManifold();
              contact.GetWorldManifold(wm);
              blockCenter = wm.m_points[0].Copy();
              return $(_this.game).one("poststep", function() {
                var direction;
                direction = wm.m_normal.Copy();
                direction.Multiply(Block.SIZE / 2 - _this.constructor.BULLET_RADIUS / 2);
                blockCenter.Add(direction);
                return _this.game.createBlock(blockCenter.x, blockCenter.y);
              });
            }
          }
        });
        $(this).on("gotDestroyed", this.unregister);
        $(this).on("destroyed", function(evt, what) {
          if (!(what instanceof _this.player.constructor)) {
            return;
          }
          return _this.player.incrementScore();
        });
      }

      Bullet.prototype.makeBody = function() {
        var body, bodyDef, fixDef;
        bodyDef = new b2.BodyDef();
        bodyDef.type = b2.Body.b2_dynamicBody;
        bodyDef.bullet = true;
        bodyDef.position.SetV(this.pos);
        bodyDef.linearVelocity.SetV(this.dir);
        bodyDef.linearVelocity.Multiply(this.constructor.BULLET_SPEED);
        body = this.game.world.CreateBody(bodyDef);
        fixDef = new b2.FixtureDef();
        fixDef.density = 0.0;
        fixDef.friction = 0.0;
        fixDef.restitution = 0;
        fixDef.shape = new b2.CircleShape(this.constructor.BULLET_RADIUS);
        body.CreateFixture(fixDef);
        return body;
      };

      Bullet.prototype.isVisible = function(player) {
        return true;
      };

      Bullet.prototype.prestep = function() {
        return this.body.ApplyForce(this.game.world.GetGravity().GetNegative(), this.body.GetWorldCenter());
      };

      Bullet.prototype.poststep = function() {
        this.oldPosition = this.currentPosition.Copy();
        return this.currentPosition = this.body.GetWorldCenter().Copy();
      };

      Bullet.prototype.canSee = function(player) {
        return true;
      };

      Bullet.prototype.draw = function(renderer, defaultMethod) {
        var positionNow;
        positionNow = this.currentPosition;
        renderer.cq.beginPath().strokeStyle(this.color()).moveTo(this.oldPosition.x, this.oldPosition.y).lineTo(positionNow.x, positionNow.y).stroke();
        return defaultMethod();
      };

      Bullet.prototype.color = function() {
        if (this.bulletType === "create") {
          return "green";
        } else {
          return "red";
        }
      };

      return Bullet;

    })(Entity);
    return Bullet;
  });

}).call(this);
