(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define([], function() {
    var Lobby;
    return Lobby = (function() {
      function Lobby(socket, yourName) {
        this.socket = socket;
        this.yourName = yourName;
        this.updateHTML = __bind(this.updateHTML, this);
        this.isHost = __bind(this.isHost, this);
        this.update = __bind(this.update, this);
        this.sendUpdate = __bind(this.sendUpdate, this);
        this.constructHTML = __bind(this.constructHTML, this);
        this.join = __bind(this.join, this);
        this.el = $("#lobby");
        this.constructHTML();
        this.update({
          players: [],
          properties: {},
          hostId: void 0
        });
      }

      Lobby.prototype.join = function() {
        var _this = this;
        this.socket.emit('join', parseInt(window.location.pathname.replace("/", ""), 10), this.yourName);
        return this.socket.on('currentlobby', function(state) {
          return _this.update(state);
        });
      };

      Lobby.prototype.constructHTML = function() {
        var createNumericControl, self,
          _this = this;
        self = this;
        this.el.append("<h3> Players: </h3>");
        this.el.players = $("<div id='players'></div>").appendTo(this.el);
        this.el.startButton = $("<button>Start</button>").appendTo(this.el).on("click", function(evt) {
          return _this.socket.emit('gamestart', _this.properties);
        });
        this.el.propertiesDiv = $("<div/>").appendTo("#lobby");
        createNumericControl = function(name, displayName, min, max) {
          _this.el.append(displayName);
          return _this.el[name] = $("<input>").attr({
            type: "number",
            min: min,
            max: max
          }).appendTo(_this.el).change("input", function(evt) {
            self.properties[name] = parseInt($(this).val(), 10);
            return self.sendUpdate();
          });
        };
        createNumericControl("scoreLimit", "Score Limit", 1, 1000);
        createNumericControl("mapWidth", "Map Width", 10, 100);
        createNumericControl("mapHeight", "Map Height", 10, 100);
        createNumericControl("randomSeed", "Seed Number", -Infinity, Infinity);
        return this.el.hostControlNames = ["startButton", "scoreLimit", "mapWidth", "mapHeight", "randomSeed"];
      };

      Lobby.prototype.sendUpdate = function() {
        return this.socket.emit('updateProperties', this.properties);
      };

      Lobby.prototype.update = function(state) {
        this.players = state.players;
        this.properties = state.properties;
        this.hostId = state.host;
        return this.updateHTML();
      };

      Lobby.prototype.isHost = function() {
        return (!!this.hostId) && this.players[this.hostId].name === this.yourName;
      };

      Lobby.prototype.updateHTML = function() {
        var idx, name, player, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
        this.el.scoreLimit.val(this.properties.scoreLimit);
        _ref = this.el.hostControlNames;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i];
          if (this.properties[name]) {
            this.el[name].val(this.properties[name]);
          }
        }
        this.el.players.empty();
        _ref1 = this.players;
        for (idx in _ref1) {
          player = _ref1[idx];
          this.el.players.append("<p>" + player.name + "</p>");
        }
        _ref2 = this.el.hostControlNames;
        _results = [];
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          name = _ref2[_j];
          _results.push(this.el[name].prop("disabled", this.isHost()));
        }
        return _results;
      };

      return Lobby;

    })();
  });

}).call(this);
