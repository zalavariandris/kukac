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
            console.log "controller dom loaded", self
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
            console.log 'kukac changed: ', change.new


        #set default values
        self.fps = 6
        self.bounds = new Bounds(new Vector(0,0), new Vector($(self.view).width(), $(self.view).height()));

        #reset
        self.reset()

        #add keydown event
        global.document.addEventListener "keydown", (event)=>
            #prevent window scroll
            event.preventDefault() if event.keyIdentifier in ["U+0020","Left", "Right", "Up", "Down"]
            switch event.keyIdentifier
                when "Left"  then self.kukac.set 'direction', new Vector(-1, 0)
                when "Right" then self.kukac.set 'direction', new Vector( 1, 0)
                when "Up"    then self.kukac.set 'direction', new Vector( 0,-1)
                when "Down"  then self.kukac.set 'direction', new Vector( 0, 1)
                when "U+0020" then self.togglePause()
                else
                    if @get 'paused' then @startGameloop()

        #animation
        @stopGameloop()
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
                  

        self.kukac.move()

        #updateView
        self.updateView()

        ###   GAME OVER   ###
        #if kukac hits the wall
        unless @bounds.contains self.kukac.get "position" then @gameOver()

        #if kukac hits itselfs
        for ring in self.kukac.rings[ 1.. ]
            dist = ring.get('position').dist self.kukac.get 'position'
            if dist < self.kukac.get 'width' then @gameOver()

        ###   EAT  ###
        for apple in self.get 'apples'
            do (apple)->
                dst = apple.get('position').dist self.kukac.get('position')
                if dst < apple.get('size')/2+self.kukac.get('width')/2
                    self.kukac.grow()
                    self.removeFrom 'apples', apple
                    self.dropAnApple()
       
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

    removeViewForApple: (apple)->
        self = this
        element = self.viewForApple.getValue apple
        $(element).remove()
        self.viewForApple.set(apple, undefined)

    updateView: ->
        self = this
        
        ### RINGS ###
        #get new rings added
        newRings = []
        for ring in self.kukac.rings
            do (ring)->
                RingHasAssociatedView = if self.viewForRing.getValue(ring) then true else false
                #console.log "RingHasAssociatedView", RingHasAssociatedView
                unless RingHasAssociatedView then newRings.push ring

        #get rings to remove
        oldRings = []
        for oldring in self.viewForRing.getKeys()
            do (oldring)->
                ViewHasAssociatedRing = if self.kukac.rings.indexOf(oldring) >= 0 then true else false
                unless ViewHasAssociatedRing then oldRings.push oldring


        #create views for new rings
        for ring in newRings
            do (ring)->
                circle = document.createElement "div"
                $(circle).addClass('warmring')
                circle.style.position = "absolute"
                circle.style.width = ring.get('radius')*2+"px"
                circle.style.height = ring.get('radius')*2+"px"

                self.viewForRing.set(ring, circle)
                $(self.view).prepend circle
        
        #remove views for oldRings
        for oldring in oldRings
            do (oldring)->
                element = self.viewForRing.getValue oldring
                $(element).fadeOut
                    duration: 500
                    complete:->
                        $(this).remove()

                self.viewForRing.set(oldring, undefined)
        

        #update views for current rings
        for ring in self.kukac.rings
            do (ring) ->
                circle = self.viewForRing.getValue(ring)
                ringPos = ring.get 'position'
                circle.style.left = ringPos.x-ring.get('radius')+"px"
                circle.style.top = ringPos.y-ring.get('radius')+"px"


    showMessage: (message)->
        $(self.popup).fadeIn()
        $(self.popup).html message

    hideMessage: ->
        $(self.popup).fadeOut()

#======================================
#         Manage Gameloop
#--------------------------------------
    
    togglePause: ->
        console.log 'toggle pause'
        if @get 'paused'
            @startGameloop()
        else
            @stopGameloop()
    
    reset: ->
        self = this

        self.kukac = new Kukac
        self.kukac.set "position", new Vector(50, 50)
        self.kukac.set "direction",  new Vector(1, 0)
        self.objects = [self.kukac]   

    killKukac: ->
        self = this
        self.reset()
        console.log "kill kukac"

    gameOver: ->
        @killKukac()
        @stopGameloop()
        @showMessage "<h2>Game Over!</h2> <br> Press a button to restart!"

    startGameloop: ->
        self = this
        self.timer = setInterval ->
            self.gameloop()
        ,1000/self.fps
        @set 'paused', false

    stopGameloop: ->
        self = this
        clearInterval self.timer
        @set 'paused', true
