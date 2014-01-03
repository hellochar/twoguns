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



  Random
