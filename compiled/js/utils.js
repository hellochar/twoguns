(function() {
  define(["underscore"], function(_) {
    var Utils;
    Utils = {
      nextIterator: function(iter, cb) {
        if (iter) {
          cb(iter);
          return Utils.nextIterator(iter.next, cb);
        }
      },
      nextArray: function(nexts) {
        var arr;
        arr = [];
        while (nexts !== null) {
          arr.push(nexts);
          nexts = nexts.m_next;
        }
        return arr;
      },
      make: function(klass, obj) {
        return _.extend(klass.prototype, obj);
      }
    };
    return Utils;
  });

}).call(this);
