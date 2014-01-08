
unless navigator.webkitGetGamepads then alert "Gamepad is not supported..."

gamepads = navigator.webkitGetGamepads()



class @PS3


    @searchForActiveGamepad: (callback)->
        status = "searching..."

        #console.log 'searching for gamepads'

        ### detect active gamepad ###

        #get current gamepads
        gamepads = navigator.webkitGetGamepads()

        #loop trhrough new gamepads
        if @gamepads
            for index in [0..gamepads.length]
                stored_gamepad = @gamepads[ index ]
                new_gamepad = gamepads[ index ]
                if stored_gamepad
                    difference = @btnDifferenceInGamepads(stored_gamepad, new_gamepad)
                    if difference.length > 0
                        status = "found"
                        callback new_gamepad

        #store new gamepads in Static variable
        @gamepads = (_.clone(gamepad) for gamepad in gamepads)

        #console.log 'searching for gamepad'
        unless status == "found"
            window.requestAnimationFrame =>
                @searchForActiveGamepad(callback)
            , 1000

    @btnDifferenceInGamepads: (gamepad_A, gamepad_B)->
        difference = []
        if gamepad_A and gamepad_B
            for btnIndex in [0..gamepad_A.buttons.length]
                value_A = gamepad_A.buttons[ btnIndex ]
                value_B = gamepad_B.buttons[ btnIndex ]
                if value_A != value_B then difference.push btnIndex
            return difference

    constructor: (gamepadindex)->
        this.gamepadindex = gamepadindex
        this.ticking = false
        this._gamepadDetected = false
        this.buttons = {}

    startPolling: ->
        unless ticking
            ticking = true
            @tick()

    tick: =>
        @pollStatus()
        @scheduleNextTick()

    scheduleNextTick: ->
        window.requestAnimationFrame @tick

    pollStatus: ->
        #detect gamepad
        gamepads = navigator.webkitGetGamepads()
        gamepad = gamepads[ @gamepadindex ]
        if gamepad and !this._gamepadDetected
            @buttons = gamepad.buttons
            this._gamepadDetected = true
            console.log 'gamepad detected', gamepad

        #poll button change
        if gamepad
            for btnIndex in [0..gamepad.buttons.length]
                newValue = gamepad.buttons[ btnIndex ]
                oldValue = @buttons[ btnIndex ]
                if newValue != oldValue
                    @buttons[ btnIndex ] = newValue
                    if newValue>0 then @buttonPress( btnIndex )
            #@buttons = gamepad.buttons

            

    buttonPress: (btnIndex)->
        @fireKeyBoardOnBtn(btnIndex)
   

    fireKeyBoardOnBtn: (btnIndex) ->
        ### map button index to keyboard keyCode ###
        map = { 
            13: 40, #Down
            12: 38, #"Up"
            14: 37, #"Left",
            15: 39,  #"Right"
            9: 32   #Start->Space
        }

        keyCode = map[ btnIndex ]

        ### create keyboard event ###
        jQuery.event.trigger({ type : 'keydown', which : keyCode });

PS3.searchForActiveGamepad (gamepad)->
    ps3 = new PS3 gamepad.index
    ps3.startPolling()


