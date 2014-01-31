(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define([], function() {
    var Delegator;
    Delegator = (function() {
      function Delegator(_methods) {
        var name, _i, _len, _ref,
          _this = this;
        this._methods = _methods;
        this.forward = __bind(this.forward, this);
        _ref = this._methods;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i];
          this[name] = (function() {
            if (_this.forwardedTo[name]) {
              return _this.forwardedTo[name].apply(_this.forwardedTo, arguments);
            } else {
              return void 0;
            }
          });
        }
      }

      Delegator.prototype.forward = function(who) {
        return this.forwardedTo = who;
      };

      return Delegator;

    })();
    return Delegator;
  });

}).call(this);
