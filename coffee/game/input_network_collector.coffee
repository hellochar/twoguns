define [
  'game/inputs'
], (Inputs) ->
  class InputNetworkCollector
    # array of game/player
    constructor: (@players) ->
      # each element is a {name -> Inputs}
      # inputGroups[i] == group for frame i
      @inputGroups = []
      @playerNames = (p.name for p in @players)
      # the next frame we're trying to load
      @frame = 0

    put: (playerName, inputs, frame) =>
      group = (@inputGroups[frame] ||= {})
      # throw new Error("Put on already existing input!") if group[playerName]?
      group[playerName] ||= inputs

    isReady: () =>
      return false if not @inputGroups[@frame]?
      frameReadyNames = _.keys(@inputGroups[@frame])
      _.difference(@playerNames, frameReadyNames).length == 0 and @playerNames.length == frameReadyNames.length

    loadFrame: () =>
      throw new Error("frame #{@frame} isn't ready but is being loaded!") if not @isReady()
      group = @inputGroups[@frame]
      @frame += 1
      [p.inputs = group[p.name] for p in @players]


  return InputNetworkCollector
