define [
  'noise'
], (ClassicalNoise) ->

  class Random
    constructor: () ->
      @perlinNoise = new ClassicalNoise()

    perlin: (x, y, z) =>
      @perlinNoise.noise(x, y, z)



  Random
