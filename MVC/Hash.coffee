global = @

class @Hash
    constructor: ->
        @_values = []
        @_keys = []
    set: (key, value) ->
        if value
            this._values.push value
            this._keys.push key
        else
            index = @_keys.indexOf key
            KeyExist = if index>=0 then true else false
            if KeyExist
                @_values.splice index, 1
                @_keys.splice index, 1
            else
                console.warn "No value for '%s' key exist!", key

    getValue: (key) ->
        i = @_keys.indexOf key
        if i < 0 then return null
        else return @_values[i]

    getKey: (value) ->
        i = @_values.indexOf value
        if i < 0 then return null
        else return @_keys[i]

    getKeys: ->
        @_keys

    getValues: ->
        @_values