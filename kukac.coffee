
global = @
class @Kukac extends Observable
    @property "rings"
    @property "position"
    @property "direction"
    constructor: ->
        super()

    init: ->
        self = this
        self.set 'rings', []

        head = new Ring
        self.addTo 'rings', head

        self.addObserver 'position', (key, change)->
            self.moveRings()
            
        self.position = new Vector


    moveRings: ->
        self = this
        if self.rings.length>1
            for i in [self.rings.length-1..1] by -1
                self.rings[i].set 'position', self.rings[i-1].position.clone()
                
        head = self.rings[0]
        if head
            head.position = self.position.clone()

    grow: ->
        self = this
        newRing = new Ring
        newRing.position = self.rings[self.rings.length-1].position.clone()

        self.addTo 'rings', newRing

    shrink:->
        self = this
        last = _.last self.rings
        self.removeFrom 'rings', last

class @Ring extends Observable
    @property "position"
    init: ->
        self = this
        # self.radius = 1
        self.position = new Vector

    # draw: (ctx)->
    #     self = this
    #     ctx.beginPath()
    #     pos = self.position
    #     ctx.arc pos.x, pos.y, self.radius, 0, 2*Math.PI
    #     ctx.fill()

