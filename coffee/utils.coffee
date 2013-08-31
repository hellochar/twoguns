define [
  "underscore"
], (_) ->

  Utils = {
    nextIterator: (iter, cb) ->
      if iter
        cb(iter)
        Utils.nextIterator(iter.next, cb)
  }

  Utils
