
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



class @Model
    constructor: ->
        @_hash = new Object
        @__listeners = {}

    set: (key, value) ->
        @_hash[ key ] = value
        event = 
            type: key
            target: value
        this.__fire event
        return value

    get: (key) ->
        @_hash[ key ]

    addListener: (type, listener) ->
        unless @__listeners[ type ] then @__listeners[ type ] = []
        @__listeners[ type ].push listener

    removeListener: (type) ->
        @__listeners[ type ]?.length = 0

    __fire: (event) ->
        unless event.type then throw new Error "Event Object needs type"
        unless event.target then event.target = this

        listeners = @__listeners[event.type]
        if listeners
            for listener in listeners
                listener.call this, event


    #subscription
    # addObserver: (observer, event)->
    #     observers = @_events[ event ]
    #     unless observers then observers = []
    #     observers.push observer
    #     @_events[ event ] = observers

    # notifyObserversForEvent: (event, observed)->
    #     observers = @_events[event]
    #     if observers?
    #         for observer in observers
    #             do (observer)->
    #                 if observer.observe instanceof Function
    #                     observer.observe(event, observed)
    #         return observers.length

    # observe: (event, observed)->


class @Kukac extends Model
    constructor: ->
        super()
        self = this
        self.speed = 20
        self.width = 20

        head = new Ring
        head.radius = self.width / 2 * 1.2
        self.rings = [head]
        

        self.addListener 'position', (event)->
            console.log "position has changed"
            #move rings
            if self.rings.length>1
                for i in [self.rings.length-1..1] by -1
                    self.rings[i].set 'position', self.rings[i-1].get('position').clone()

            self.rings[0].set 'position', self.get('position').clone()

        self.set "position", new Vector

    move: ->
        self = this
        pos = self.get "position"
        pos.add self.get('direction').clone().scale self.speed
        self.set "position", pos

    grow: ->
        self = this
        newRing = new Ring
        newRing.radius = self.width/2
        newRing.set 'position', self.rings[self.rings.length-1].get('position').clone()
        self.rings.push(newRing);

    draw: (ctx)->
        self = this
        ring.draw(ctx) for ring in self.rings

class @Ring extends Model
    constructor: ->
        super()
        self = this
        self.radius = 1
        self.set 'position', new Vector

    draw: (ctx)->
        self = this
        ctx.beginPath()
        pos = self.get 'position'
        ctx.arc pos.x, pos.y, self.radius, 0, 2*Math.PI
        ctx.fill()

