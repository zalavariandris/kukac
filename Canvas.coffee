global = @


class @CanvasView
    constructor: (canvasElement)->
        this.subviews = []
        this.ctx = canvasElement.getContext "2d"

    draw: ->
        self = this
        self.ctx.clearRect 0, 0, self.ctx.canvas.width, self.ctx.canvas.height
        #object.draw(self.view.ctx) for object in self.objects
        for view in @subviews
            do (view) -> view.draw(self.ctx)

class @Circle
    constructor: ->
        @position = new Vector
        @radius = 5

    draw: (ctx) ->
                self = this
                ctx.beginPath()
                ctx.arc self.position.x, self.position.y, self.radius, 0, 2*Math.PI
                ctx.fill()