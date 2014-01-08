
global = @


class @Kukac extends Observable
    constructor: ->
        super()

    init: ->
        self = this
        self.set 'width', 20
        self.set 'rings', []

        head = new Ring
        head.set 'radius', self.get('width')/ 2 * 1.0
        self.addTo 'rings', head

        self.addObserver 'position', (key, change)->
            self.moveRings()
            

        self.set "position", new Vector

    moveRings: ->
        self = this
        if self.get('rings').length>1
            for i in [self.get('rings').length-1..1] by -1
                # ringBefore = self.get('rings')[i-1]
                # ring = self.get('rings')[i]
                # posBefore = ringBefore.get 'position'
                # ringPos = ring.get 'position'
                # delta = ringPos.clone().sub posBefore.clone()
                # delta.norm().scale(10)
                # console.log delta
                # if delta.x and delta.y
                #     ring.set 'position', posBefore.clone().add(delta)
                self.get('rings')[i].set 'position', self.get('rings')[i-1].get('position').clone()
                
        head = self.get('rings')[0]
        if head
            head.set 'position', self.get('position').clone()

    grow: ->
        self = this
        newRing = new Ring
        newRing.set 'radius', self.get('width')/2
        newRing.set 'position', self.get('rings')[self.get('rings').length-1].get('position').clone()
        self.addTo 'rings', newRing

    shrink:->
        self = this
        last = _.last self.get 'rings'
        self.removeFrom 'rings', last

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

