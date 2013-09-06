define [
  "underscore"
  "b2"
], (_, b2) ->

  Utils = {

    getInset: (vertices, insetAmount) ->
      insetVertices = []
      l = vertices.length
      for i in [0...l]
        last_idx = (i - 1 + l) % l
        this_idx = i
        next_idx = (i + 1) % l

        last_pt = vertices[last_idx]
        this_pt = vertices[this_idx]
        next_pt = vertices[next_idx]

        prev_offset = this_pt.Copy()
        prev_offset.Subtract(last_pt)
        next_offset = next_pt.Copy()
        next_offset.Subtract(this_pt)

        getInset = (offset) ->
          angle = Math.atan2( offset.y, offset.x ) + Math.PI / 2
          return new b2.Vec2( insetAmount * Math.cos(angle), insetAmount * Math.sin(angle) )

        prev_inset = getInset(prev_offset)
        next_inset = getInset(next_offset)

        inset_pt = this_pt.Copy()
        inset_pt.Add( prev_inset )
        inset_pt.Add( next_inset )
        insetVertices.push( inset_pt )

      return insetVertices

    }

  Utils
