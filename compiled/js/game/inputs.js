(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['underscore', 'b2'], function(_, b2) {
    var Inputs;
    Inputs = (function() {
      function Inputs(mouse, keys) {
        this.mouse = mouse;
        this.keys = keys;
        this.pressed = __bind(this.pressed, this);
        this.serialize = __bind(this.serialize, this);
        this.toWorld = __bind(this.toWorld, this);
        this.mouseup = __bind(this.mouseup, this);
        this.mousedown = __bind(this.mousedown, this);
        this.setLocation = __bind(this.setLocation, this);
        this.clone = __bind(this.clone, this);
        this.mouse || (this.mouse = {});
        this.keys || (this.keys = {});
        _.defaults(this.mouse, {
          x: 0,
          y: 0,
          button: -1,
          down: false
        });
        _.defaults(this.keys, {});
      }

      Inputs.prototype.clone = function() {
        return new Inputs(_.clone(this.mouse), _.clone(this.keys));
      };

      Inputs.prototype.setLocation = function(x, y) {
        this.mouse.x = x;
        return this.mouse.y = y;
      };

      Inputs.prototype.mousedown = function(x, y, button) {
        this.setLocation(x, y);
        this.mouse.button = button;
        return this.mouse.down = true;
      };

      Inputs.prototype.mouseup = function(x, y, button) {
        this.setLocation(x, y);
        return this.mouse.button = -1;
      };

      Inputs.prototype.toWorld = function(renderer) {
        var c;
        c = this.clone();
        c.mouse.location = renderer ? renderer.worldVec2(new b2.Vec2(this.mouse.x, this.mouse.y)) : new b2.Vec2(0, 0);
        delete c.mouse.x;
        delete c.mouse.y;
        return c;
      };

      Inputs.prototype.serialize = function() {
        return JSON.stringify(this);
      };

      Inputs.unserialize = function(string) {
        var keys, mouse, _ref;
        _ref = JSON.parse(string), mouse = _ref.mouse, keys = _ref.keys;
        return new Inputs(mouse, keys);
      };

      Inputs.prototype.pressed = function(key) {
        return key in this.keys;
      };

      return Inputs;

    }).call(this);
    return Inputs;
  });

}).call(this);
