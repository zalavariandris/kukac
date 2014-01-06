global = @
class @Apple extends Observable
    init: ->
        @set 'position', new Vector(100,100)
        @set 'size', 20