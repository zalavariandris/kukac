class Garden extends Observable
    @property "apples"
    @property "bounds"
    @property "kukac"

    init: ()->
        @apples = []
        @bounds = new Bounds new Vector(0,0), new Vector( 9, 9)

    dropAnApple: ->
        self = this
        apple = new Apple

        randomx = Math.round Math.random()*@bounds.getWidth() 
        randomy = Math.round Math.random()*@bounds.getHeight()
        
        apple.position = new Vector randomx
        apple.set 'position', new Vector randomx, randomy
        @addTo 'apples', apple


class GameController extends Controller
    @property "garden"

    # @property 'kukac'
    @property "paused"
    @property "currentTimestep"
    @property "initialTimestep"
    @property "gridstep"
    

    init: ->
        #animation
        this._round = 0
        
        this._view
        this._pupupView

        #model
        this._viewForRing = new Hash

        #this.apples = []
        this._viewForApple = new Hash

        # @apples = []
        @garden = new Garden

        

    startSyncWithStorage: ()->
        @initialTimestep = Number localStorage.initialTimestep or 200
        @addObserver "initialTimestep", ()=>
            localStorage.initialTimestep = @initialTimestep

        @gridstep = Number localStorage.gridstep or 20
        @addObserver 'gridstep', ()=>
            localStorage.gridstep = @gridstep

        data = JSON.parse(localStorage.bounds)
        @garden.bounds = new Bounds(data.tl or 15, data.br or 15)
        @garden.addObserver 'bounds', ()=>
            data = {tl: @garden.bounds.tl, br: @garden.bounds.br}
            localStorage.bounds = JSON.stringify(data)


        @_view.style.left = localStorage.viewLeft
        @_view.style.top = localStorage.viewTop
        $(@_view).on "dragstop", (event, ui)=>
            localStorage.viewLeft = @_view.style.left
            localStorage.viewTop = @_view.style.top

    windowDidLoad: ->
        self = this

        #setup views
        self._view = document.getElementById "kukacdiv"
        self._view.style.position = "relative"
        self._toolsView = document.getElementById "tools"
        self._popupView = document.getElementById "popup"

        
        # ===================================
        #           USER INTERFACE
        # -----------------------------------
        $(self._view).draggable()
        $(self._view).resizable
            grid: [@gridstep, @gridstep]

        $(self._view).resize (event, ui)=>
            width = $(event.target).width() / @gridstep - 1
            height = $(event.target).height() / @gridstep - 1
            @garden.bounds = new Bounds new Vector(0,0), new Vector(width, height)

        # BIND UI
        # bind main view
        updateViewSize = ()=>
            self._view.style.width = (@garden.bounds.getWidth()+1) * @gridstep + "px"
            self._view.style.height = (@garden.bounds.getHeight()+1) * @gridstep + "px"
        updateViewSize()
        @garden.addObserver "bounds", updateViewSize
        self.addObserver "gridstep", updateViewSize
        
        # BIND TOOLS VIEW
        # timestep
        $(@_toolsView).on "change", "[name=initialTimestep]", (event, ui)=>
            @["initialTimestep"] = Number event.target.value
            $(event.target).blur()

        @addObserver "initialTimestep", (key, change)=>
            $("[name=initialTimestep]", @_toolsView).val change.new
            @currentTimestep = @initialTimestep

        # gridstep
        $(@_toolsView).on "mousedown", "[name=gridstep]", (event, ui)=>
            @_gardenWidth = $(@_view).width()
            @_gardenHeight = $(@_view).height()

        $(@_toolsView).on "change", "[name=gridstep]", (event, ui)=>
            console.log "gridstep"
            @["gridstep"] = Number event.target.value
            @garden["bounds"] = new Bounds new Vector(0,0), new Vector Math.round(@_gardenWidth / @["gridstep"]), Math.round(@_gardenHeight / @["gridstep"])
            $(event.target).blur()

        @addObserver "gridstep", (key, change)=>
            $("[name=gridstep]", @_toolsView).val change.new

        # HIDE CURSOR
        $(document).mousemove (event, ui)=>
            console.log "move"
            document.body.style.cursor = "pointer"

            clearTimeout @_hideCursorTimeout
            @_hideCursorTimeout = setTimeout ()->
                document.body.style.cursor = "none"
            , 1000
            
        # LOAD SAVE
        @startSyncWithStorage()

        ### observe itself ###
        @addObserver 'paused', (key, change)->
            if self.paused
                self.showMessage 'press a button to continue...'
            else
                self.hideMessage()

        @garden.addObserver 'apples', (key, change) ->
            for apple in change.added
                do (apple)->
                    self.addViewForApple apple
            for apple in change.removed
                do (apple)->
                    self.removeViewForApple apple

        ### observe kukac ###
        @garden.addObserver 'kukac', (key, change)->
            #console.log 'kukac changed: ', change
            change.old?.removeObservers 'rings'
            if change.old
                for ring in change.old.rings
                    do ->
                        self.removeViewForRing ring
            if change.new
                for ring in change.new.rings
                    do (ring)->
                        self.addViewForRing ring
            change.new.addObserver 'rings', (key, change)->
                #console.log 'rings changed:', change.kind 
                for ring in change.added
                    do (ring)->
                        self.addViewForRing ring
                for ring in change.removed
                    do (ring)->
                        self.removeViewForRing ring


        #reset
        self.reset()

        # probably map for PS3 Controller, and this in not used here at all...
        map = { 
            13: 40, #Down
            12: 38, #"Up"
            14: 37, #"Left",
            15: 39  #"Right"
        }

        #add keydown event
        $(document).keydown (event)=>
            #console.log 'app keydown: ', event.which
            if @paused
                @play()
            else if event.which == 32
                @pause()
            newDir = new Vector
            switch event.which
                when 37 then newDir = new Vector(-1, 0) #Left 
                when 39 then newDir = new Vector( 1, 0) #Right 
                when 38 then newDir = new Vector( 0,-1) #Up 
                when 40 then newDir = new Vector( 0, 1) #Down 
                else
                    newDir = @garden.kukac.direction
            @garden.kukac.direction = newDir           

        #animation
        @pause()
        @showMessage('Press a button to start!')

        @garden.dropAnApple()

    windowDidUnload: ->
        console.log "unload"


#======================================
#         Manage Gameloop
#--------------------------------------
    reset: ->
        self = this
        kukac = new Kukac
        kukac.set "direction",  new Vector(1, 0)
        kukac.set "position", new Vector(2, 2)
        @garden.kukac = kukac

        @currentTimestep = @initialTimestep
        return

    killKukac: ->
        self = this
        console.log "kill kukac"
        self.reset()

    gameOver: ->
        @_round = 0
        @killKukac()
        @pause()
        @showMessage "<h2>Game Over!</h2> <br> Press a button to restart!"
      

#======================================
#            Game Loop
#-------------------------------------- 
    gameloop: ->
        self = this

        ###    ANIMATE    ###
        # gro kukac at the first 4 round
        @_round++
        if @_round < 4 then @garden.kukac.grow()

        #grow kukac regularly
        if Math.random()<0.2 then @garden.kukac.grow()

        ### move kukac ###
        pos = @garden.kukac.position
        pos.add @garden.kukac.direction #.clone().scale self.gridstep
        @garden.kukac.position = pos

        ###   EAT  ###
        for apple in self.garden.apples
            do (apple)->
                dst = apple.position.dist self.garden.kukac.position
                if dst < 1
                    #shrink kukac
                    self.garden.kukac.shrink()

                    #remove the apple
                    self.garden.removeFrom 'apples', apple
                    #drop anotherone
                    self.garden.dropAnApple()
                    #increase timestep
                    self.currentTimestep *= 0.98

        ###   GAME OVER   ###
        #if kukac hits the wall
        unless @garden.bounds.contains self.garden.kukac.position then @gameOver()

        #if kukac hits itselfs
        for ring in self.garden.kukac.rings[ 1.. ]
            dist = ring.position.dist self.garden.kukac.position
            if dist < 1 then @gameOver()

        if self.garden.kukac.rings.length <= 0 then @gameOver()

    tick: ->
        @gameloop()
        unless @paused
            clearTimeout( @_timer )
            @_timer = setTimeout =>
                @tick()
            ,@currentTimestep

    play: ->
        @paused = false
        @tick()
        return

    pause: ->
        @paused = true
       
#======================================
#            Update Views
#--------------------------------------
    addViewForApple: (apple)->
        self = this
        circle = document.createElement "div"
        $(circle).addClass('apple')
        circle.style.position = "absolute"

        updateCirclePosition = (circle, apple)=>
            circle.style.top = apple.position.y*@gridstep+"px"
            circle.style.left = apple.position.x*@gridstep+"px"
            circle.style.width = @gridstep+"px"
            circle.style.height = @gridstep+"px"

        updateCirclePosition circle, apple

        self.addObserver "gridstep", (key, change)=>
            circle = self._viewForApple.getValue(apple)
            updateCirclePosition circle, apple
            return

        self._viewForApple.set(apple, circle)
        $(self._view).prepend circle

    removeViewForApple: (apple)->
        self = this
        element = self._viewForApple.getValue apple
        $(element).remove()
        
    addViewForRing: (ring) ->
        self = this
        circle = document.createElement "div"
        $(circle).addClass('warmring')
        circle.style.position = "absolute"
        self._viewForRing.set(ring, circle)
        $(self._view).prepend circle

        #RING
        updateCirclePosition = (circle, ring)=>
            circle.style.left = ring.position.x*@gridstep+"px"
            circle.style.top = ring.position.y*@gridstep+"px"

        updateCircleSize = (circle, ring)=>
            circle.style.width = @gridstep+"px"
            circle.style.height = @gridstep+"px"

        updateCirclePosition(circle, ring)
        updateCircleSize circle, ring

        ring.addObserver "position", (key, change)->
            updateCirclePosition self._viewForRing.getValue(ring), ring

        self.addObserver "gridstep", (key, change)->
            circle = self._viewForRing.getValue(ring)
            updateCircleSize circle, ring
            updateCirclePosition circle, ring

    removeViewForRing: (ring)->
        self = this
        element = self._viewForRing.getValue ring

        $(element).fadeOut(
            200,
            ->
                $(element).remove()
        )


    showMessage: (message)->
        self = this
        $(self._popupView).html message
        $(self._popupView).fadeIn()
        
    hideMessage: ->
        self = this
        $(self._popupView).fadeOut() 


@GameController = GameController
