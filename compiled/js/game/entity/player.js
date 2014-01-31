(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'b2', 'utils', 'overlay', 'game/entity/entity', 'game/entity/bullet', 'game/world/player_body', 'game/entity/block'], function(jquery, b2, Utils, Overlay, Entity, Bullet, PlayerBody, Block) {
    var Player;
    Player = (function(_super) {
      __extends(Player, _super);

      function Player(name, game, index) {
        var _this = this;
        this.name = name;
        this.game = game;
        this.index = index;
        this.toString = __bind(this.toString, this);
        this.color = __bind(this.color, this);
        this.draw = __bind(this.draw, this);
        this.lookAt = __bind(this.lookAt, this);
        this.shoot = __bind(this.shoot, this);
        this.isVisible = __bind(this.isVisible, this);
        this.getVisionPoly = __bind(this.getVisionPoly, this);
        this.getCollidedBodies = __bind(this.getCollidedBodies, this);
        this.directionTo = __bind(this.directionTo, this);
        this.poststep = __bind(this.poststep, this);
        this.prestep = __bind(this.prestep, this);
        this.makeBody = __bind(this.makeBody, this);
        this.incrementScore = __bind(this.incrementScore, this);
        Player.__super__.constructor.call(this, this.game);
        this.score = 0;
        this.bullet_sound = new Audio();
        this.bullet_sound.src = "gun-gunshot-02.mp3";
        this.bullet_sound.volume = .2;
        this.direction = new b2.Vec2(1, 0);
        $(this).on("gotDestroyed", function(who) {
          return setTimeout(function() {
            _this.constructBody();
            if (!_this.game.finished) {
              return Overlay.hide();
            }
          }, 3000);
        });
      }

      Player.prototype.incrementScore = function() {
        return this.score += 1;
      };

      Player.prototype.makeBody = function() {
        return PlayerBody.create(this);
      };

      Player.prototype.prestep = function() {
        var FORCE_FLY, FORCE_WALK_X, IMPULSE_DOWN, IMPULSE_JUMP, loc, vel;
        this.mouse = this.inputs.mouse;
        if (!this.body) {
          return;
        }
        IMPULSE_JUMP = new b2.Vec2(0, -0.04 / this.body.GetMass());
        IMPULSE_DOWN = new b2.Vec2(0, -0.04 / this.body.GetMass());
        FORCE_WALK_X = 4.0;
        FORCE_FLY = new b2.Vec2(0, -0.8);
        loc = this.body.GetWorldCenter().Copy();
        if (this.inputs.pressed('w') && this.body.canJump()) {
          this.body.ApplyImpulse(IMPULSE_JUMP, loc);
        }
        vel = this.body.GetLinearVelocity();
        if (this.inputs.pressed('a')) {
          this.body.SetLinearVelocity(new b2.Vec2(-FORCE_WALK_X, vel.y));
        } else if (this.inputs.pressed('d')) {
          this.body.SetLinearVelocity(new b2.Vec2(FORCE_WALK_X, vel.y));
        } else {
          this.body.SetLinearVelocity(new b2.Vec2(0, vel.y));
        }
        if (this.inputs.pressed('s')) {
          this.body.ApplyImpulse(IMPULSE_JUMP.Copy().Multiply(1 / 10), loc);
        }
        if (this.mouse.down) {
          return this.shoot({
            0: "destroy",
            2: "create"
          }[this.mouse.button]);
        }
      };

      Player.prototype.poststep = function() {
        if (!this.body) {
          return;
        }
        this.direction = this.directionTo(this.mouse.location);
        delete this.body.visionPoly;
        return delete this.body.collidedBodies;
      };

      Player.prototype.directionTo = function(x, y) {
        var direction, _ref;
        if ("x" in x && "y" in x && y === void 0) {
          _ref = x, x = _ref.x, y = _ref.y;
        }
        direction = new b2.Vec2(x, y);
        direction.Subtract(this.body.GetWorldCenter());
        direction.Normalize();
        return direction;
      };

      Player.prototype.getCollidedBodies = function() {
        if (this.body) {
          this.getVisionPoly();
          return this.body.collidedBodies;
        } else {
          return [];
        }
      };

      Player.prototype.getVisionPoly = function() {
        if (this.body) {
          return this.body.getVisionPoly();
        } else {
          return [];
        }
      };

      Player.prototype.isVisible = function(player) {
        return (player === this) || Player.__super__.isVisible.call(this, player);
      };

      Player.prototype.shoot = function(bulletType) {
        var DISTANCE_OFFSET, pos, positionOffset;
        if (!this.body) {
          return;
        }
        this.bullet_sound.currentTime = 0;
        this.bullet_sound.play();
        pos = this.body.GetWorldCenter().Copy();
        positionOffset = this.direction.Copy();
        DISTANCE_OFFSET = .5;
        positionOffset.Multiply(DISTANCE_OFFSET);
        pos.Add(positionOffset);
        return new Bullet(this, pos, this.direction, bulletType);
      };

      Player.prototype.lookAt = function(renderer, mx, my) {
        if (!this.body) {
          return;
        }
        renderer.lookAt(this.body.GetPosition());
        return renderer.center.SetV(renderer.worldVec2(new b2.Vec2(mx, my)));
      };

      Player.prototype.draw = function(renderer, defaultMethod) {
        var cq;
        if (!this.body) {
          return;
        }
        defaultMethod();
        cq = renderer.cq;
        return cq.save().translate(this.body.GetWorldCenter().x, this.body.GetWorldCenter().y).translate(0, -0.4).rotate(Math.atan2(this.direction.y, this.direction.x) + Math.PI / 2).fillStyle(this.color()).strokeStyle("red").beginPath().moveTo(-0.1, 0).lineTo(+0.1, 0).lineTo(0, -.28).closePath().stroke().fill().restore();
      };

      Player.prototype.color = function() {
        return "rgb(255, 255, 0)";
      };

      Player.prototype.toString = function() {
        return "[" + this.name + " (" + this.index + ")]";
      };

      return Player;

    })(Entity);
    return Player;
  });

}).call(this);
