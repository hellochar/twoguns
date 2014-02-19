define [
  'underscore'
  'game/inputs'
], (_, Inputs) ->

  # Usage:
  #   1. construct with given parameters
  #   2. put() other players' inputs (and optionally putHash() your own hash)
  #   3. call advance() with your next input to move the game forward (should only call this when
  #   @isReady() == true)
  #   4. checkHash() any hashes you recieve over the wire to ensure everyone's on the same game state
  #
  class InputNetworkCollector
    # players: array of game/player objects
    # induces feedback latency equal to FRAME_OFFSET * (ms per frame)
    constructor: (@game, @socket, @frameOffset) ->
      @players = @game.players
      # each element is a {name -> Inputs}
      # inputGroups[i] == group for frame number @frame+i
      @inputGroups = []
      @playerNames = (p.name for p in @players)
      # the next frame we're trying to load
      @frame = 0

      # holds the hashCode for the game at frame [idx]
      @hashCodes = []

      # advancedTimes[i] == unix millis when frame i was advanced
      @advancedTimes = []

      @latency = undefined

      # start off by filling in the first FRAME_OFFSET inputs with no-ops
      for frame in [0...@frameOffset]
        for player in @players
          @put(player.name, (new Inputs()).toWorld(), frame)

    advance: (input) =>
      throw new Error("frame #{@frame} isn't ready but is being loaded!") if not @isReady()
      @advancedTimes[@frame] = (new Date()).valueOf()
      thisLatency = @advancedTimes[@frame] - @advancedTimes[@frame - @frameOffset]
      if not @latency
        @latency = thisLatency
      else
        @latency = @latency * .95 + thisLatency * .05

      @socket.emit('inputPacket', input.serialize(), @frame + @frameOffset)
      @socket.emit('hashcode', @game.hashCode(), @frame)
      @putHash(@game.hashCode())
      @loadFrame()
      @frame += 1

    # approximate the latency
    getLatency: () => @latency

    put: (playerName, inputs, frame) =>
      group = (@inputGroups[frame - @frame] ||= {})
      group[playerName] ||= inputs

    putHash: (hash) =>
      @hashCodes[@frame] = hash

    removePlayer: (playerName) =>
      player = _.findWhere(name: playerName)
      @player = _.without(@players, player)
      @playerNames = (p.name for p in @players)

    isReady: () =>
      return false if not @inputGroups[0]?
      frameReadyNames = _.keys(@inputGroups[0])
      _.difference(@playerNames, frameReadyNames).length == 0 and @playerNames.length == frameReadyNames.length

    # mutates each player in @players to have the input for the current frame
    loadFrame: () =>
      group = @inputGroups.shift()
      [p.inputs = group[p.name] for p in @players]

    checkHash: (hash, frame) =>
      throw new Error("Frame #{frame} desync: hash #{hash} doesn't match with mine #{@hashCodes[frame]}") if hash isnt @hashCodes[frame]


  return InputNetworkCollector
