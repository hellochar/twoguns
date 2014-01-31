(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['jquery'], function($) {
    var Scoreboard;
    Scoreboard = (function() {
      function Scoreboard(game) {
        this.game = game;
        this.poststep = __bind(this.poststep, this);
        this.game.register(this);
        this.el = $("<div>").css({
          position: "absolute",
          top: "0px",
          right: "0px",
          color: "white"
        }).appendTo("body");
      }

      Scoreboard.prototype.poststep = function() {
        var player, row, _i, _len, _ref, _results;
        this.el.empty();
        _ref = _.sortBy(this.game.players, function(player) {
          return -1 * player.score;
        });
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          player = _ref[_i];
          row = $("<div>").text("" + player.name + " - " + player.score).appendTo(this.el);
          if (player === this.game.youPlayer) {
            _results.push(row.css("background-color", "black"));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      return Scoreboard;

    })();
    return Scoreboard;
  });

}).call(this);
