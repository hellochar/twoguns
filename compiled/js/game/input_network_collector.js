(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['underscore', 'game/inputs'], function(_, Inputs) {
    var InputNetworkCollector;
    InputNetworkCollector = (function() {
      function InputNetworkCollector(game, socket, frameOffset) {
        var frame, p, player, _i, _j, _len, _ref, _ref1;
        this.game = game;
        this.socket = socket;
        this.frameOffset = frameOffset;
        this.checkHash = __bind(this.checkHash, this);
        this.loadFrame = __bind(this.loadFrame, this);
        this.isReady = __bind(this.isReady, this);
        this.removePlayer = __bind(this.removePlayer, this);
        this.putHash = __bind(this.putHash, this);
        this.put = __bind(this.put, this);
        this.getLatency = __bind(this.getLatency, this);
        this.advance = __bind(this.advance, this);
        this.players = this.game.players;
        this.inputGroups = [];
        this.playerNames = (function() {
          var _i, _len, _ref, _results;
          _ref = this.players;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _results.push(p.name);
          }
          return _results;
        }).call(this);
        this.frame = 0;
        this.hashCodes = [];
        this.advancedTimes = [];
        this.latency = void 0;
        for (frame = _i = 0, _ref = this.frameOffset; 0 <= _ref ? _i < _ref : _i > _ref; frame = 0 <= _ref ? ++_i : --_i) {
          _ref1 = this.players;
          for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
            player = _ref1[_j];
            this.put(player.name, (new Inputs()).toWorld(), frame);
          }
        }
      }

      InputNetworkCollector.prototype.advance = function(input) {
        var thisLatency;
        if (!this.isReady()) {
          throw new Error("frame " + this.frame + " isn't ready but is being loaded!");
        }
        this.advancedTimes[this.frame] = (new Date()).valueOf();
        thisLatency = this.advancedTimes[this.frame] - this.advancedTimes[this.frame - this.frameOffset];
        if (!this.latency) {
          this.latency = thisLatency;
        } else {
          this.latency = this.latency * .95 + thisLatency * .05;
        }
        this.socket.emit('inputPacket', input.serialize(), this.frame + this.frameOffset);
        this.socket.emit('hashcode', this.game.hashCode(), this.frame);
        this.putHash(this.game.hashCode());
        this.loadFrame();
        return this.frame += 1;
      };

      InputNetworkCollector.prototype.getLatency = function() {
        return this.latency;
      };

      InputNetworkCollector.prototype.put = function(playerName, inputs, frame) {
        var group, _base, _name;
        group = ((_base = this.inputGroups)[_name = frame - this.frame] || (_base[_name] = {}));
        return group[playerName] || (group[playerName] = inputs);
      };

      InputNetworkCollector.prototype.putHash = function(hash) {
        return this.hashCodes[this.frame] = hash;
      };

      InputNetworkCollector.prototype.removePlayer = function(playerName) {
        var p, player;
        player = _.findWhere({
          name: playerName
        });
        this.player = _.without(this.players, player);
        return this.playerNames = (function() {
          var _i, _len, _ref, _results;
          _ref = this.players;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _results.push(p.name);
          }
          return _results;
        }).call(this);
      };

      InputNetworkCollector.prototype.isReady = function() {
        var frameReadyNames;
        if (this.inputGroups[0] == null) {
          return false;
        }
        frameReadyNames = _.keys(this.inputGroups[0]);
        return _.difference(this.playerNames, frameReadyNames).length === 0 && this.playerNames.length === frameReadyNames.length;
      };

      InputNetworkCollector.prototype.loadFrame = function() {
        var group, p;
        group = this.inputGroups.shift();
        return [
          (function() {
            var _i, _len, _ref, _results;
            _ref = this.players;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              p = _ref[_i];
              _results.push(p.inputs = group[p.name]);
            }
            return _results;
          }).call(this)
        ];
      };

      InputNetworkCollector.prototype.checkHash = function(hash, frame) {
        if (hash !== this.hashCodes[frame]) {
          throw new Error("Frame " + frame + " desync: hash " + hash + " doesn't match with mine " + this.hashCodes[frame]);
        }
      };

      return InputNetworkCollector;

    })();
    return InputNetworkCollector;
  });

}).call(this);
