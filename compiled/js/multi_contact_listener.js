(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'box2d'], function($, Box2D) {
    var MultiContactListener;
    MultiContactListener = (function(_super) {
      __extends(MultiContactListener, _super);

      function MultiContactListener() {
        this.PostSolve = __bind(this.PostSolve, this);
        this.PreSolve = __bind(this.PreSolve, this);
        this.EndContact = __bind(this.EndContact, this);
        this.BeginContact = __bind(this.BeginContact, this);
        this.triggerContactEvent = __bind(this.triggerContactEvent, this);
      }

      MultiContactListener.prototype.triggerContactEvent = function(eventName, contact) {
        $(this.world).trigger(eventName, contact);
        $(contact.GetFixtureA().GetBody()).trigger(eventName, [contact, contact.GetFixtureA(), contact.GetFixtureB()]);
        $(contact.GetFixtureB().GetBody()).trigger(eventName, [contact, contact.GetFixtureB(), contact.GetFixtureA()]);
        $(contact.GetFixtureA()).trigger(eventName, [contact, contact.GetFixtureA(), contact.GetFixtureB()]);
        return $(contact.GetFixtureB()).trigger(eventName, [contact, contact.GetFixtureB(), contact.GetFixtureA()]);
      };

      MultiContactListener.prototype.BeginContact = function(contact) {
        return this.triggerContactEvent("begincontact", contact);
      };

      MultiContactListener.prototype.EndContact = function(contact) {
        return this.triggerContactEvent("endcontact", contact);
      };

      MultiContactListener.prototype.PreSolve = function(contact, oldManifold) {};

      MultiContactListener.prototype.PostSolve = function(contact, impulse) {};

      return MultiContactListener;

    })(Box2D.Dynamics.b2ContactListener);
    return MultiContactListener;
  });

}).call(this);
