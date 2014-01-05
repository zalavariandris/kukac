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


class @Controller
#======================================
#            Initialization
#-------------------------------------- 
    constructor: ->
        #properties
        this.fps
        #animation
        this.timer
        
        #model
        this.kukac
        this.viewForRing = new Hash;

        #view
        self = this
        window.addEventListener "load", ->
            console.log "controller dom loaded", self
            self.didLoad()

        window.addEventListener "unload", ->
            self.didUnload()

    didLoad: ->
        self = this

        #setup view
        #canvas = document.getElementById "myCanvas"
        #self.view = new CanvasView(canvas)
        self.view = document.getElementById "kukacdiv"
        self.view.style.position = "relative"

        #set properties
        self.fps = 6
        self.bounds = new Bounds(new Vector(0,0), new Vector($(self.view).width(), $(self.view).height()));

        #reset
        self.reset()        

        #add keydown event
        global.document.addEventListener "keydown", (event)->
            #prevent window scroll
            event.preventDefault() if event.keyIdentifier in ["Left", "Right", "Up", "Down"]

            switch event.keyIdentifier
                when "Left"  then self.kukac.direction = new Vector(-1, 0)
                when "Right" then self.kukac.direction = new Vector( 1, 0)
                when "Up"    then self.kukac.direction = new Vector( 0,-1)
                when "Down"  then self.kukac.direction = new Vector( 0, 1)

        #animation
        self.startGameloop()

    didUnload: ->
        console.log "unload"
        self = this
        self.stopGameloop()  

#======================================
#            Game Loop
#-------------------------------------- 
    gameloop: ->
        self = this
        #animate kukac
        if Math.random()<0.0 then self.kukac.grow()
        self.kukac.move()

        #updateView
        self.updateView()

        ###   GAME OVER   ###
        #if kukac hits the wall
        unless @bounds.contains self.kukac.position then self.killKukac()

        #if kukac hits itselfs
        for ring in self.kukac.rings[ 1.. ]
            dist = ring.position.dist self.kukac.position
            if dist < self.kukac.width then self.killKukac()
       
#======================================
#            Update View
#-------------------------------------- 
    updateView: ->
        console.time "updateView"
        self = this
        if self.view instanceof CanvasView
            circles = []
            for ring in self.kukac.rings 
                do (ring)->
                    circle = new Circle
                    circle.position = ring.position
                    circle.radius = ring.radius
                    circles.push circle
            self.view.subviews = circles
            self.view.draw()

        else if self.view instanceof Element
            self = this
            
            #get new models
            newRings = []
            for ring in self.kukac.rings
                do (ring)->
                    RingHasAssociatedView = if self.viewForRing.getValue(ring) then true else false
                    #console.log "RingHasAssociatedView", RingHasAssociatedView
                    unless RingHasAssociatedView then newRings.push ring

            #create dom for new rings
            for ring in newRings
                do (ring)->
                    circle = document.createElement "div"
                    $(circle).addClass('warmring')
                    circle.style.position = "absolute"
                    circle.style.width = ring.radius*2+"px"
                    circle.style.height = ring.radius*2+"px"

                    self.viewForRing.set(ring, circle)
                    $(self.view).prepend circle

            #get old views
            oldRings = []
            for oldring in self.viewForRing.getKeys()
                do (oldring)->
                    ViewHasAssociatedRing = if self.kukac.rings.indexOf(oldring) >= 0 then true else false
                    unless ViewHasAssociatedRing then oldRings.push oldring
            
            #remove oldViews
            for oldring in oldRings
                do (oldring)->
                    element = self.viewForRing.getValue oldring
                    $(element).fadeOut
                        duration: 500
                        complete:->
                            $(this).remove()

                    self.viewForRing.set(oldring, undefined)
            

            #update views
            for ring in self.viewForRing.getKeys()
                do (ring) ->
                    circle = self.viewForRing.getValue(ring)
                    circle.style.left = ring.position.x-ring.radius+"px"
                    circle.style.top = ring.position.y-ring.radius+"px"

            #console.timeEnd "updateView"


            # $(self.view).empty()
            # for ring in self.kukac.rings 
            #     do (ring)->
            #         circle = document.createElement "div"
            #         circle.style.width = ring.radius*2+"px"
            #         circle.style.height = ring.radius*2+"px"
            #         circle.style.position = "absolute"
            #         circle.style.left = ring.position.x-ring.radius+"px"
            #         circle.style.top = ring.position.y-ring.radius+"px"
            #         circle.style.borderRadius = ring.radius+"px"
            #         circle.style.background = "red"
            #         $(self.view).append(circle)

#======================================
#         Manage Gameloop
#--------------------------------------
    
    reset: ->
        self = this

        self.kukac = new Kukac
        self.kukac.setPosition new Vector(50, 50)
        self.kukac.direction = new Vector(1, 0)
        self.objects = [self.kukac]   

    killKukac: ->
        self = this
        self.reset()
        console.log "kill kukac"

    startGameloop: ->
        self = this
        self.timer = setInterval ->
            self.gameloop()
        ,1000/self.fps

    stopGameloop: ->
        self = this
        clearInterval self.timer
