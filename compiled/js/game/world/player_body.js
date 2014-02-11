(function() {
  define(['jquery', 'underscore', 'b2', 'settings', 'game/entity/bullet'], function($, _, b2, settings, Bullet) {
    var BODYDEF, FIXDEF, PlayerBody, pbMethods,
      _this = this;
    BODYDEF = new b2.BodyDef;
    BODYDEF.type = b2.Body.b2_dynamicBody;
    BODYDEF.fixedRotation = true;
    BODYDEF.allowSleep = false;
    FIXDEF = new b2.FixtureDef;
    FIXDEF.density = 1.0;
    FIXDEF.friction = 0;
    FIXDEF.restitution = 0;
    FIXDEF.shape = new b2.PolygonShape;
    PlayerBody = {
      create: function(player, height, width) {
        var body, game, pos;
        if (height == null) {
          height = settings.player.height;
        }
        if (width == null) {
          width = settings.player.width;
        }
        game = player.game;
        pos = game.findEmptyAABB(1, .5);
        BODYDEF.position.SetV(pos.lowerBound);
        body = game.world.CreateBody(BODYDEF);
        (function() {
          var FEET_HEIGHT, FEET_WIDTH, impl, methodName, _results,
            _this = this;
          FIXDEF.shape.SetAsBox(width / 2, height / 2);
          this.torso = this.CreateFixture(FIXDEF);
          FEET_HEIGHT = 0.001;
          FEET_WIDTH = width / 2 - .005;
          FIXDEF.shape.SetAsVector([new b2.Vec2(FEET_WIDTH, height / 2), new b2.Vec2(FEET_WIDTH, height / 2 + FEET_HEIGHT), new b2.Vec2(-FEET_WIDTH, height / 2 + FEET_HEIGHT), new b2.Vec2(-FEET_WIDTH, height / 2)]);
          this.feet = this.CreateFixture(FIXDEF);
          this.player = player;
          this.game = game;
          this.world = this.game.world;
          this.jumpCounter = 0;
          $(this.feet).on("begincontact", function(evt, contact, myFixture, otherFixture) {
            return _this.jumpCounter += 1;
          });
          $(this.feet).on("endcontact", function(evt, contact, myFixture, otherFixture) {
            return _this.jumpCounter -= 1;
          });
          _results = [];
          for (methodName in pbMethods) {
            impl = pbMethods[methodName];
            _results.push(this[methodName] = impl.bind(this));
          }
          return _results;
        }).bind(body)();
        return body;
      }
    };
    pbMethods = {
      canJump: function() {
        return this.jumpCounter > 0;
      },
      getVisionPoly: function() {
        if (this.visionPoly == null) {
          this.calculateVisionPoly();
        }
        return this.visionPoly;
      },
      calculateVisionPoly: function() {
        var angle, dir, isect, offset, point, poly, _i, _ref, _ref1,
          _this = this;
        poly = [];
        this.collidedBodies = [];
        for (angle = _i = 0, _ref = Math.PI * 2, _ref1 = (Math.PI * 2) / settings.player.visionPolyDetail; _ref1 > 0 ? _i <= _ref : _i >= _ref; angle = _i += _ref1) {
          dir = new b2.Vec2(Math.cos(angle), Math.sin(angle));
          isect = this.game.rayIntersect(this.GetWorldCenter(), dir, function(fixture) {
            return fixture.GetBody() !== _this && !(fixture.GetBody().GetUserData() instanceof Bullet);
          }, 30);
          this.collidedBodies.push(isect != null ? isect.fixture.GetBody() : void 0);
          point = isect != null ? isect.point : void 0;
          if (!point) {
            point = this.GetWorldCenter().Copy();
            offset = dir.Copy();
            offset.Multiply(30);
            point.Add(offset);
          }
          poly.push(point);
        }
        return this.visionPoly = poly;
      },
      shoot: function(bulletType) {
        var DISTANCE_OFFSET, pos, positionOffset;
        this.bullet_sound.currentTime = 0;
        this.bullet_sound.play();
        pos = this.GetWorldCenter().Copy();
        positionOffset = this.direction.Copy();
        DISTANCE_OFFSET = .5;
        positionOffset.Multiply(DISTANCE_OFFSET);
        pos.Add(positionOffset);
        return new Bullet(this.player, pos, this.direction, bulletType);
      }
    };
    return PlayerBody;
  });

}).call(this);
