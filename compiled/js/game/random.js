(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['seedrandom', 'noise'], function(seedrandom, ClassicalNoise) {
    var Random;
    Random = (function() {
      function Random(seed) {
        var rng;
        if (seed == null) {
          seed = 0;
        }
        this.float = __bind(this.float, this);
        this.perlin = __bind(this.perlin, this);
        rng = seedrandom(seed);
        this.myRandom = {
          random: function() {
            return rng();
          }
        };
        this.perlinNoise = new ClassicalNoise(this.myRandom);
      }

      Random.prototype.perlin = function(x, y, z) {
        return this.perlinNoise.noise(x, y, z);
      };

      Random.prototype.float = function(low, high) {
        var _ref;
        if (!low) {
          low = 1;
        }
        if (!high) {
          _ref = [low, 0], high = _ref[0], low = _ref[1];
        }
        return this.myRandom.random() * (high - low) + low;
      };

      return Random;

    })();
    return Random;
  });

}).call(this);
