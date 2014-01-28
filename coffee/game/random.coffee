define [
  'seedrandom'
  'noise'
], (seedrandom, ClassicalNoise) ->

  class Random
    constructor: (seed = 0) ->
      rng = seedrandom(seed)
      @myRandom = {
        random: () -> rng()
      }
      @perlinNoise = new ClassicalNoise(@myRandom)

    perlin: (x, y, z) =>
      @perlinNoise.noise(x, y, z)

    float: (low, high) =>
      if not low
        low = 1
      if not high
        [high, low] = [low, 0]
      @myRandom.random() * (high - low) + low



  Random
