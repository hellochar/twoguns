(function() {
  var __slice = [].slice;

  define(['underscore'], function(_) {
    var Registerable;
    return Registerable = function() {
      var eventNames;
      eventNames = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return {
        register: function(listener) {
          var name, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = eventNames.length; _i < _len; _i++) {
            name = eventNames[_i];
            if (listener[name] != null) {
              _results.push($(this).on(name, listener[name]));
            }
          }
          return _results;
        },
        unregister: function(listener) {
          var name, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = eventNames.length; _i < _len; _i++) {
            name = eventNames[_i];
            if (listener[name] != null) {
              _results.push($(this).off(name, listener[name]));
            }
          }
          return _results;
        }
      };
    };
  });

}).call(this);
