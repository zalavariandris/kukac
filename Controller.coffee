global = @

class @Controller extends Observable
#======================================
#            Initialization
#-------------------------------------- 
    constructor: ->
        #properties
        this.fps
        #animation
        this.timer
        this.paused
        
        this.view
        this.pupup
        #model
        this.viewForRing = new Hash;
        #this.apples = []
        this.viewForApple = new Hash;

        #trigger didLoad when dom is loaded
        self = this
        window.addEventListener "load", ->
            self.didLoad()

        window.addEventListener "unload", ->
            self.didUnload()

        super()
    init: ->
        @set 'apples', []
    didLoad: ->
        self = this

        #setup views
        self.view = document.getElementById "kukacdiv"
        self.view.style.position = "relative"

        self.popup = document.getElementById "pupup"

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



        #set default values
        self.fps = 6
        self.bounds = new Bounds(new Vector(0,0), new Vector($(self.view).width(), $(self.view).height()));

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

    didUnload: ->
        console.log "unload"
        self = this
        @stopGameloop()  

#======================================
#            Game Loop
#-------------------------------------- 
    dropAnApple: ->
        self = this
        apple = new Apple

        step = 20
        width = self.bounds.getWidth()-step
        height = self.bounds.getHeight()-step
        randomx = Math.random()
        randomy = Math.random()
        

        apple.set 'position', new Vector(
                                    Math.round(randomx * width / step) / Math.round( width / step)*width+step/2,
                                    Math.round(randomy * height / step) / Math.round( height / step)*height+step/2
                                    )
        self.addTo 'apples', apple

    gameloop: ->
        self = this
        #animate kukac
        #if Math.random()<0.2 then self.kukac.grow()
                  
        if self.get('kukac').get('rings').length < 4 then self.get('kukac').grow()
        self.get('kukac').move()

        ###   GAME OVER   ###
        #if kukac hits the wall
        unless @bounds.contains self.get('kukac').get "position" then @gameOver()

        #if kukac hits itselfs
        for ring in self.get('kukac').get('rings')[ 1.. ]
            dist = ring.get('position').dist self.get('kukac').get 'position'
            if dist < self.get('kukac').get 'width' then @gameOver()

        ###   EAT  ###
        for apple in self.get 'apples'
            do (apple)->
                dst = apple.get('position').dist self.get('kukac').get('position')
                if dst < apple.get('size')/2+self.get('kukac').get('width')/2
                    self.get('kukac').grow()
                    self.removeFrom 'apples', apple
                    self.dropAnApple()

        

    tick: ->
        @gameloop()
        unless @get 'paused'
            setTimeout =>
                @tick()
            ,1000/@fps

    play: ->
        @set 'paused', false
        @tick()
        return

    pause: ->
        @set 'paused', true
       
#======================================
#            Update View
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

        self.viewForApple.set(apple, circle)
        $(self.view).prepend circle

        #bind model to view
        apple.addObserver 'size', (key, change)->
            console.log "apple changed", this
            view = self.viewForApple.getValue( this )
            view.style.width = change.new+"px"
            view.style.height = change.new+"px"

    removeViewForApple: (apple)->
        self = this
        element = self.viewForApple.getValue apple

        $(element).remove()
        self.viewForApple.set(apple, undefined)

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

        self.viewForRing.set(ring, circle)
        $(self.view).prepend circle

        #bind model to view
        ring.addObserver "position", (key, change)->
            view = self.viewForRing.getValue(ring)
            ringPos = ring.get 'position'
            view.style.left = ringPos.x-ring.get('radius')+"px"
            view.style.top = ringPos.y-ring.get('radius')+"px"

    removeViewForRing: (ring)->
        self = this
        element = self.viewForRing.getValue ring
        $(element).remove()
        self.viewForRing.set(ring, undefined)

    showMessage: (message)->
        $(self.popup).fadeIn()
        $(self.popup).html message

    hideMessage: ->
        $(self.popup).fadeOut()

#======================================
#         Manage Gameloop
#--------------------------------------
    
    reset: ->
        self = this
        kukac = new Kukac
        kukac.set "direction",  new Vector(1, 0)
        kukac.set "position", new Vector(90, 50)
        self.set 'kukac', kukac

    killKukac: ->
        self = this
        console.log "kill kukac"
        self.reset()

    gameOver: ->
        @killKukac()
        @pause()
        @showMessage "<h2>Game Over!</h2> <br> Press a button to restart!"
        
