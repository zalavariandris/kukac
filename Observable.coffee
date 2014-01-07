global = @


class @Observable
    constructor: ->
        @_hash = new Object
        @__observers = {}

        @init()

    init: ->

    set: (key, value) ->
        change =
            kind: "SET",
            added: [value]
            removed: []
            old: @_hash[ key ],
            new: value

        @_hash[ key ] =  value 

        @__fire key, change
        return @_hash[ key ]

    get: (key) ->
        @_hash[ key ]

    addTo: (key, value) ->
        #copy current array
        oldArray = @_hash[ key ].slice()
        #add new item
        @_hash[key].push value

        change =
            kind: "ADDITION",
            added: [value]
            removed: []
            old: oldArray,
            new: @_hash[key]

        @__fire key, change
        return @_hash[ key ]

    removeFrom: (key, value) ->
        #copt current array
        oldArray = @_hash[ key ].slice()
        #remove item
        index = @_hash[ key ].indexOf value
        @_hash[ key ].splice index, 1

        change =
            kind: "REMOVAL",
            added: [ ],
            removed: [ value ],
            old: oldArray,
            new: @_hash[ key ]

        @__fire key, change

    __fire: (key, change) ->
        unless key then throw new Error "Event Object needs type"

        observers = @__observers[ key ]
        if observers
            for observer in observers
                observer.call this, key, change

    addObserver: (key, observer) ->
        #create observer array for key not exist then create one
        unless @__observers[ key ] then @__observers[ key ] = []
        #add new observer to key
        @__observers[ key ].push observer

    removeObservers: (key) ->
        @__observers[ key ]?.length = 0

    