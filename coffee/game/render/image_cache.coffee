define [
], () ->
  mapping = {}
  ImageCache = {
    get: (url) ->
      if not (url of mapping)
        img = new Image()
        img.src = url
        mapping[url] = img
      mapping[url]
  }

  return ImageCache
