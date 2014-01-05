
global = @

class @Model
    constructor: ->
        @_hash = new Object
        @_events = {}

    set: (key, value) ->
        @_hash[ key ] = value
        @notifyObserversForEvent key, this
    get: (key) ->
        @_hash[ key ]

    #subscription
    addObserver: (observer, event)->
        observers = @_events[ event ]
        unless observers then observers = []
        observers.push observer
        @_events[ event ] = observers

    notifyObserversForEvent: (event)->
        observers = @_events[event]
        for observer in observers
            do (observer)->
                if observer.observe instanceof Function
                    observer.observe()

    observe: (event, observed)->



class @Kukac
    constructor: ->
        self = this
        self.direction = new Vector
        self.speed = 10
        self.width = 10

        head = new Ring
        head.radius = self.width / 2 * 1.2
        self.rings = [head]
        self.setPosition new Vector



    setPosition: (pos)->
        self = this
        self.position = pos

        #move rings
        if self.rings.length>1
            for i in [self.rings.length-1..1] by -1
                self.rings[i].position = self.rings[i-1].position.clone()

        self.rings[0].position = self.position.clone()

    getPosition: ->
        self = this
        self.position

    move: ->
        self = this
        pos = self.getPosition()
        pos.add self.direction.clone().scale self.speed
        self.setPosition pos

    grow: ->
        self = this
        newRing = new Ring
        newRing.radius = self.width/2
        newRing.position = self.rings[self.rings.length-1].position.clone()
        self.rings.push(newRing);

    draw: (ctx)->
        self = this
        ring.draw(ctx) for ring in self.rings

class @Ring
    constructor: ->
        self = this
        self.radius = 1
        self.position = new Vector

    draw: (ctx)->
        self = this
        ctx.beginPath()
        ctx.arc self.position.x, self.position.y, self.radius, 0, 2*Math.PI
        ctx.fill()

