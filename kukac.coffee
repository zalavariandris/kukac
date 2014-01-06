
global = @

# class @Observer
#     @_fields: []
#     constructor: ->
#         console.log "fields: ",
#         Object.defineProperties
#         for property in @constructor._fields
#             do ->


# class @Sub extends Observer
#     @_fields:["paused, hello"]




class @Kukac extends Observable
    constructor: ->
        this.head
        this.rings = []
        super()

    init: ->
        self = this
        self.set 'speed', 20
        self.set 'width', 20

        head = new Ring
        head.set 'radius', self.get('width')/ 2 * 1.2
        self.rings.push head

        self.addObserver 'position', (event)->
            #move rings
            if self.rings.length>1
                for i in [self.rings.length-1..1] by -1
                    self.rings[i].set 'position', self.rings[i-1].get('position').clone()

            self.rings[0].set 'position', self.get('position').clone()

        self.set "position", new Vector

    move: ->
        self = this
        pos = self.get "position"
        pos.add self.get('direction').clone().scale self.get 'speed'
        self.set "position", pos

    grow: ->
        self = this
        newRing = new Ring
        newRing.set 'radius', self.get('width')/2
        newRing.set 'position', self.rings[self.rings.length-1].get('position').clone()
        self.rings.push newRing

class @Ring extends Observable
    init: ->
        self = this
        self.set 'radius', 1
        self.set 'position', new Vector

    draw: (ctx)->
        self = this
        ctx.beginPath()
        pos = self.get 'position'
        ctx.arc pos.x, pos.y, self.get 'radius', 0, 2*Math.PI
        ctx.fill()

