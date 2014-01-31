(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['underscore'], function(_) {
    var Entity;
    Entity = (function() {
      function Entity(game) {
        this.game = game;
        this.unregister = __bind(this.unregister, this);
        this.destroy = __bind(this.destroy, this);
        this.draw = __bind(this.draw, this);
        this.isVisible = __bind(this.isVisible, this);
        this.constructBody = __bind(this.constructBody, this);
        this.game.entities.push(this);
        this.game.register(this);
        this.constructBody();
      }

      Entity.prototype.constructBody = function() {
        if (this.makeBody != null) {
          this.body = this.makeBody();
        }
        return this.body.SetUserData(this);
      };

      Entity.prototype.isVisible = function(player) {
        if (this.body) {
          return _.contains(player.getCollidedBodies(), this.body);
        } else {
          return false;
        }
      };

      Entity.prototype.draw = function(renderer, defaultMethod) {
        return defaultMethod();
      };

      Entity.prototype.destroy = function(who) {
        if (!this.body) {
          return;
        }
        this.game.world.DestroyBody(this.body);
        $(this).trigger("gotDestroyed", who);
        if (who) {
          $(who).trigger("destroyed", this);
        }
        return delete this.body;
      };

      Entity.prototype.unregister = function() {
        this.game.entities = _.without(this.game.entities, this);
        return this.game.unregister(this);
      };

      return Entity;

    })();
    return Entity;
  });

}).call(this);
