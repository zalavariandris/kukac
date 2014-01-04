AppController = function(){
    var self = this;
    self.canvas = undefined;
    self.objects = [];
    self.timer = undefined;
    self.context = undefined;

    document.addEventListener("DOMContentLoaded",  function(){
        console.log('dom loaded', self);
        self.didLoad();
    }, false);
}

AppController.prototype.didLoad = function(){
    var self = this;

    self.fps = 3;

    self.kukac = new Kukac();

    self.objects.push(self.kukac);

    var canvas = document.getElementById("myCanvas");

    document.addEventListener('keydown', function(event){
        event.keyIdentifier === "Left"
        switch (event.keyIdentifier){
            case "Left":
                self.kukac.direction = {x:-1, y: 0};
            break;
            case "Right":
                self.kukac.direction = {x: 1, y: 0};
            break;
            case "Up":
                self.kukac.direction = {x: 0, y:-1};
            break;
            case "Down":
                self.kukac.direction = {x: 0, y: 1};
            break;
            default:
                "key pressed";
            break;
        }
    });

    self.context = canvas.getContext("2d");

    self.startAnimation();
}

AppController.prototype.draw = function(){
    var self = this;
    self.context.clearRect(0,0, self.context.canvas.width, self.context.canvas.height);
    for(var i=0;i<self.objects.length;i++){
        var object = self.objects[i];
        object.draw(self.context);
    }
}

AppController.prototype.animation = function(){
    var self = this;

    self.kukac.move();
}

AppController.prototype.startAnimation = function(){
    var self = this;
    self.timer = setInterval(function(){
        self.animation();
        self.draw()
    }, 1000/self.fps);
}

AppController.prototype.stopAnimation = function(){
    var self = this;
    clearInterval( self.timer );
}




