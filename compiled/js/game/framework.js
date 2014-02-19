(function() {
  define(['underscore', 'b2', 'canvasquery', 'overlay', 'settings', 'game/game', 'game/inputs', 'game/random', 'game/input_network_collector', 'game/render/renderer'], function(_, b2, cq, Overlay, settings, Game, Inputs, Random, InputNetworkCollector, Renderer) {
    var framework;
    framework = {
      isRunning: function() {
        return !!this.hasSetup;
      },
      setup: function(socket, gameProperties) {
        var _this = this;
        if (this.isRunning()) {
          throw new Error("framework.setup() called more than once!");
        }
        this.hasSetup = true;
        this.socket = socket;
        this.gameProperties = gameProperties;
        this.cq = cq().framework(this, this);
        this.cq.canvas.oncontextmenu = function() {
          return false;
        };
        this.cq.appendTo("body");
        this.input = new Inputs({
          x: this.cq.canvas.width / 2,
          y: this.cq.canvas.height / 2
        }, {});
        this.game = new Game(gameProperties.mapWidth, gameProperties.mapHeight, gameProperties.playerNames, gameProperties.yourName, new Random(gameProperties.randomSeed));
        window.you = this.game.youPlayer;
        this.renderer = new Renderer(18, this.game, this.cq);
        this.networkCollector = new InputNetworkCollector(this.game, this.socket, settings.frameOffset);
        (function() {
          var indicator, invocations;
          invocations = 0;
          indicator = $("<div/>").appendTo("#debughud");
          $(_this.game).on('rayintersectall', function() {
            return invocations += 1;
          });
          return $(_this.renderer).on('rendered', function() {
            indicator.text("" + invocations + " ray intersections!");
            return invocations = 0;
          });
        })();
        (function() {
          var latencydiv;
          latencydiv = $("<div>").appendTo("#debughud");
          return $(_this.game).on('poststep', function() {
            return latencydiv.text("" + (Math.floor(_this.networkCollector.getLatency())) + " ms ping");
          });
        })();
        this.statsStep = new Stats();
        this.statsStep.setMode(0);
        this.statsStep.domElement.style.left = '0px';
        this.statsStep.domElement.style.top = '0px';
        this.statsRender = new Stats();
        this.statsRender.setMode(0);
        this.statsRender.domElement.style.left = '0px';
        this.statsRender.domElement.style.top = '50px';
        $("#debughud").append(this.statsStep.domElement);
        return $("#debughud").append(this.statsRender.domElement);
      },
      onStep: function(delta, time) {
        var playerInput;
        if (this.input.pressed('dash')) {
          this.renderer.viewportWidth *= 1.05;
        }
        if (this.input.pressed('equal')) {
          this.renderer.viewportWidth /= 1.05;
        }
        if (this.networkCollector.isReady() && !this.game.finished) {
          this.statsStep.begin();
          playerInput = this.input.toWorld(this.renderer);
          this.networkCollector.advance(playerInput);
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
