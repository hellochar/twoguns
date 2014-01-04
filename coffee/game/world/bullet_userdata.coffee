define [
], () ->
  class BulletUserData
    draw: (renderer, defaultMethod) =>
      defaultMethod()
    color: () => "red"

  return BulletUserData

