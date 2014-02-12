global = @

class @Controller extends Observable
#======================================
#            Initialization
#-------------------------------------- 
    constructor: ->
        #properties

        #animation
        this._round = 0
        this._gridstep = 20
        
        this._view
        this._pupupView

        #model
        this._viewForRing = new Hash;

        #this.apples = []
        this._viewForApple = new Hash;

        #trigger didLoad when dom is loaded
        #self = this
        window.addEventListener "load", =>
            @windowDidLoad()

        window.addEventListener "unload", =>
            @windowDidUnload()

        super()

    init: ->
        @set 'apples', []

    windowDidLoad: ->
        self = this
        console.log "app did load"

        #setup views
        self._view = document.getElementById "kukacdiv"
        self._view.style.position = "relative"
        self.bounds = new Bounds(new Vector(0,0), new Vector($(self._view).width(), $(self._view).height()));

        self._popupView = document.getElementById "popup"

        ### observe itself ###
        @addObserver 'paused', (key, change)->
            if self.get 'paused'
                self.showMessage 'press a button to continue...'
            else
                self.hideMessage()

        @addObserver 'apples', (key, change) ->
            for apple in change.added
                do (apple)->
                    self.addViewForApple apple
            for apple in change.removed
                do (apple)->
                    self.removeViewForApple apple

        ### observe kukac ###
        @addObserver 'kukac', (key, change)->
            #console.log 'kukac changed: ', change
            change.old?.removeObservers 'rings'
            if change.old
                for ring in change.old.get 'rings'
                    do ->
                        self.removeViewForRing ring
            if change.new
                for ring in change.new.get 'rings'
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

        map = { 
            13: 40, #Down
            12: 38, #"Up"
            14: 37, #"Left",
            15: 39  #"Right"
        }

        #add keydown event
        $(document).keydown (event)=>
            #console.log 'app keydown: ', event.which
            if @get 'paused'
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
                    newDir = @get('kukac').get('direction')

            kukac = @get 'kukac'
            kukac.set 'direction', newDir           

        #animation
        @pause()
        @showMessage('Press a button to start!')

        @dropAnApple()

    windowDidUnload: ->
        console.log "unload"


#======================================
#         Manage Gameloop
#--------------------------------------
    
    reset: ->
        self = this
        kukac = new Kukac
        kukac.set "direction",  new Vector(1, 0)
        kukac.set "position", new Vector(90, 50)
        self.set 'kukac', kukac
        self.timestep = 360

    killKukac: ->
        self = this
        console.log "kill kukac"
        self.reset()

    gameOver: ->
        @_round = 0
        @killKukac()
        @pause()
        @showMessage "<h2>Game Over!</h2> <br> Press a button to restart!"

    dropAnApple: ->
        self = this
        apple = new Apple

        width = self.bounds.getWidth() - self._gridstep
        height = self.bounds.getHeight() - self._gridstep
        randomx = Math.random()
        randomy = Math.random()
        

        apple.set 'position', new Vector(
                                    Math.round(randomx * width / self._gridstep) / Math.round( width / self._gridstep)*width+self._gridstep/2,
                                    Math.round(randomy * height / self._gridstep) / Math.round( height / self._gridstep)*height+self._gridstep/2
                                    )
        self.addTo 'apples', apple
      

#======================================
#            Game Loop
#-------------------------------------- 
    gameloop: ->
        self = this

        ###    ANIMATE    ###
        # gro kukac at the first 4 round
        @_round++
        if @_round < 4 then @get('kukac').grow()

        #grow kukac regularly
        if Math.random()<0.1 then self.get('kukac').grow()

        ### move kukac ###
        kukac = @get 'kukac'
        pos = kukac.get 'position'
        pos.add kukac.get('direction').clone().scale self._gridstep
        kukac.set 'position', pos

        ###   EAT  ###
        for apple in self.get 'apples'
            do (apple)->
                dst = apple.get('position').dist self.get('kukac').get('position')
                if dst*1.1 < apple.get('size')/2+self.get('kukac').get('width')/2
                    #shrink kukac
                    self.get('kukac').shrink()

                    #remove the apple
                    self.removeFrom 'apples', apple
                    #drop anotherone
                    self.dropAnApple()
                    #increase timestep
                    self.timestep *= 0.98

        ###   GAME OVER   ###
        #if kukac hits the wall
        unless @bounds.contains self.get('kukac').get "position" then @gameOver()

        #if kukac hits itselfs
        for ring in self.get('kukac').get('rings')[ 1.. ]
            dist = ring.get('position').dist self.get('kukac').get 'position'
            if dist < self.get('kukac').get 'width' then @gameOver()

        if self.get('kukac').get('rings').length <= 0 then @gameOver()

    tick: ->
        @gameloop()
        unless @get 'paused'
            clearTimeout( @_timer )
            @_timer = setTimeout =>
                @tick()
            ,@timestep

    play: ->
        @set 'paused', false
        @tick()
        return

    pause: ->
        @set 'paused', true
       
#======================================
#            Update Views
#--------------------------------------
    addViewForApple: (apple)->
        self = this
        circle = document.createElement "div"
        $(circle).addClass('apple')
        circle.style.position = "absolute"
        applePos = apple.get 'position'
        circle.style.top = applePos.y-apple.get('size')/2+"px"
        circle.style.left = applePos.x-apple.get('size')/2+"px"
        circle.style.width = apple.get('size')+"px"
        circle.style.height = apple.get('size')+"px"

        self._viewForApple.set(apple, circle)
        $(self._view).prepend circle

        #bind model to view
        apple.addObserver 'size', (key, change)->
            apple = this
            view = self._viewForApple.getValue( this ) 
            view.style.width = change.new+"px"
            view.style.height = change.new+"px"

    removeViewForApple: (apple)->
        self = this
        element = self._viewForApple.getValue apple
        $(element).remove()
        
    addViewForRing: (ring) ->
        self = this
        circle = document.createElement "div"
        $(circle).addClass('warmring')
        circle.style.position = "absolute"
        circle.style.width = ring.get('radius')*2+"px"
        circle.style.height = ring.get('radius')*2+"px"
        ringPos = ring.get 'position'
        circle.style.left = ringPos.x-ring.get('radius')+"px"
        circle.style.top = ringPos.y-ring.get('radius')+"px"

        self._viewForRing.set(ring, circle)
        $(self._view).prepend circle

        #bind model to view
        ring.addObserver "position", (key, change)->
            view = self._viewForRing.getValue(ring)
            ringPos = ring.get 'position'
            view.style.left = ringPos.x-ring.get('radius')+"px"
            view.style.top = ringPos.y-ring.get('radius')+"px"

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
