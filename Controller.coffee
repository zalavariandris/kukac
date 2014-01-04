global = @
class @Controller
    constructor: ->
        console.log "controller contruct"
        this.fps
        this.canvas
        this.objects = []
        this.timer
        this.context
        this.kukac

        self = this
        document.addEventListener "DOMContentLoaded", ->
            console.log "controller dom loaded", self
            self.didLoad()

    didLoad: ->
        console.log "conrtoller did load wooo"
        self = this
        
        self.fps = 3

        self.kukac = new Kukac
        self.objects.push self.kukac

        canvas = document.getElementById "myCanvas"
        self.ctx = canvas.getContext "2d"

        global.document.addEventListener "keydown", (event)->
            switch event.keyIdentifier
                when "Left"  then self.kukac.direction = new Vector(-1, 0)
                when "Right" then self.kukac.direction = new Vector( 1, 0)
                when "Up"    then self.kukac.direction = new Vector( 0,-1)
                when "Down"  then self.kukac.direction = new Vector( 0, 1)

        self.startAnimation()

    draw: ->
        self = this
        self.ctx.clearRect 0, 0, self.ctx.canvas.width, self.ctx.canvas.height
        object.draw(self.ctx) for object in self.objects

    animation: ->
        self = this
        self.kukac.move()

        #game overs
        #if kukac hit wall

    startAnimation: ->
        self = this
        self.timer = setInterval ->
            self.animation()
            self.draw()
        ,1000/self.fps

    stopAnimation: ->
        self = this
        clearInterval self.timer

    + (a)->
        console.log "overload", a
