console.log "Controller.coffe executed"

global = @

class @Controller extends Observable

    
    # @property 'apples'
#======================================
#            Initialization
#-------------------------------------- 
    constructor: ->
        #trigger didLoad when dom is loaded
        #self = this
        window.addEventListener "load", =>
            @windowDidLoad()

        window.addEventListener "unload", =>
            @windowDidUnload()

        super() 
