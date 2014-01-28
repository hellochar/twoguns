define [
  "underscore"
], (_) ->

  Utils = {
    nextIterator: (iter, cb) ->
      if iter
        cb(iter)
        Utils.nextIterator(iter.next, cb)

    nextArray: (nexts) ->
      arr = []
      while(nexts != null)
        arr.push(nexts)
        nexts = nexts.m_next
      arr

    make: (klass, obj) ->
      _.extend(klass.prototype, obj)
  }

  Utils
