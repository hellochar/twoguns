(function() {
  define(['underscore', 'b2', 'canvasquery', 'overlay', 'game/game', 'game/inputs', 'game/random', 'game/input_network_collector', 'game/render/renderer'], function(_, b2, cq, Overlay, Game, Inputs, Random, InputNetworkCollector, Renderer) {
    var FRAME_OFFSET, framework;
    FRAME_OFFSET = 1;
    framework = {
      isRunning: function() {
        return !!this.hasSetup;
      },
      setup: function(socket, gameProperties) {
        var frame, player, _i, _j, _len, _ref,
          _this = this;
        if (this.isRunning()) {
          throw new Error("framework.setup() called more than once!");
        }
        this.hasSetup = true;
        this.socket = socket;
        this.gameProperties = gameProperties;
        this.cq = cq().framework(this, this);
        this.cq.appendTo("body");
        this.input = new Inputs({
          x: this.cq.canvas.width / 2,
          y: this.cq.canvas.height / 2
        }, {});
        this.game = new Game(gameProperties.mapWidth, gameProperties.mapHeight, gameProperties.playerNames, gameProperties.yourName, new Random(gameProperties.randomSeed));
        window.you = this.game.youPlayer;
        this.renderer = new Renderer(18, this.game, this.cq);
        this.networkCollector = new InputNetworkCollector(this.game.players);
        for (frame = _i = 0; 0 <= FRAME_OFFSET ? _i < FRAME_OFFSET : _i > FRAME_OFFSET; frame = 0 <= FRAME_OFFSET ? ++_i : --_i) {
          _ref = this.game.players;
          for (_j = 0, _len = _ref.length; _j < _len; _j++) {
            player = _ref[_j];
            this.networkCollector.put(player.name, (new Inputs()).toWorld(this.renderer), frame);
          }
        }
        (function() {
          var indicator, invocations;
          invocations = 0;
          indicator = $("<div/>").appendTo("body").css({
            position: "absolute",
            left: "0px",
            top: "100px",
            background: "white"
          });
          $(_this.game).on('rayintersectall', function() {
            return invocations += 1;
          });
          return $(_this.renderer).on('rendered', function() {
            indicator.text("" + invocations + " ray intersections!");
            return invocations = 0;
          });
        })();
        this.statsStep = new Stats();
        this.statsStep.setMode(0);
        this.statsStep.domElement.style.position = 'absolute';
        this.statsStep.domElement.style.left = '0px';
        this.statsStep.domElement.style.top = '0px';
        this.statsRender = new Stats();
        this.statsRender.setMode(0);
        this.statsRender.domElement.style.position = 'absolute';
        this.statsRender.domElement.style.left = '0px';
        this.statsRender.domElement.style.top = '50px';
        document.body.appendChild(this.statsStep.domElement);
        return document.body.appendChild(this.statsRender.domElement);
      },
      onStep: function(delta, time) {
        var playerInputs;
        if (this.input.pressed('dash')) {
          this.renderer.viewportWidth *= 1.05;
        }
        if (this.input.pressed('equal')) {
          this.renderer.viewportWidth /= 1.05;
        }
        if (this.networkCollector.isReady() && !this.game.finished) {
          this.statsStep.begin();
          playerInputs = this.input.toWorld(this.renderer);
          this.socket.emit('inputPacket', playerInputs.serialize(), this.networkCollector.frame + FRAME_OFFSET);
          this.socket.emit('hashcode', this.game.hashCode(), this.networkCollector.frame);
          this.networkCollector.putHash(this.game.hashCode());
          this.networkCollector.loadFrame();
          this.game.step();
          this.checkWinCondition();
          this.input.mouse.down = false;
          return this.statsStep.end();
        }
      },
      checkWinCondition: function() {
        var winningPlayer;
        winningPlayer = _.findWhere(this.game.players, {
          score: this.gameProperties.scoreLimit
        });
        if (!winningPlayer) {
          return;
        }
        this.game.finished = true;
        if (winningPlayer === this.game.youPlayer) {
          Overlay.show("You win!!!");
        } else {
          Overlay.show("" + winningPlayer.name + " won!");
        }
        return this.socket.disconnect();
      },
      onRender: function(delta, time) {
        this.statsRender.begin();
        this.renderer.render(this.input.mouse.x, this.input.mouse.y);
        return this.statsRender.end();
      },
      onResize: function(width, height) {
        if (this.cq) {
          this.cq.canvas.height = height;
          return this.cq.canvas.width = width;
        }
      },
      onMouseDown: function(x, y, button) {
        return this.input.mousedown(x, y, button);
      },
      onMouseUp: function(x, y, button) {
        return this.input.mouseup(x, y, button);
      },
      onMouseMove: function(x, y) {
        return this.input.setLocation(x, y);
      },
      onKeyDown: function(key) {
        return this.input.keys[key] = true;
      },
      onKeyUp: function(key) {
        return delete this.input.keys[key];
      },
      onDisconnected: function(playerName) {
        if (this.networkCollector) {
          return this.networkCollector.removePlayer(playerName);
        }
      },
      onInputPacket: function(playerName, inputSerialized, frameStamp) {
        return this.networkCollector.put(playerName, Inputs.unserialize(inputSerialized), frameStamp);
      },
      onHashcode: function(hash, frame) {
        return this.networkCollector.checkHash(hash, frame);
      }
    };
    return framework;
  });

}).call(this);
