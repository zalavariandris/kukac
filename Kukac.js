//KUKAC
function Kukac(){
    var self = this;

    self.direction = {x: 1, y: 0};
    self.speed = 10.0;
    
    //rings
    self.head = new Ring;
    self.rings = [self.head];

    //
    self.setPosition({x:0, y: 0});

    for(var i=0; i<6; i++){
        self.grow();
    }
}

Kukac.prototype.setPosition = function(pos){
    var self = this;
    self.position = pos;

    //loop from last to head
    for(var i=self.rings.length-1; i>0 ; i--){
        var ring = self.rings[i];
        var nextRing = self.rings[i-1];
        ring.setPosition( nextRing.getPosition() );
    }
    self.head.setPosition( self.getPosition() );
}

Kukac.prototype.getPosition = function(){
    var self = this;
    return self.position;
}


Kukac.prototype.draw = function(ctx){
    var self = this;

    for(var i=0; i<self.rings.length; i++){
        var ring = self.rings[i];
        ring.draw(ctx);
    }
}

Kukac.prototype.move = function(){
    var self = this;
    var pos = self.getPosition();
    pos = {
        x: pos.x+self.direction.x * self.speed,
        y: pos.y+self.direction.y * self.speed
    }
    self.setPosition( pos );
}

Kukac.prototype.grow = function(){
    var self = this;
    
    self.rings.push(new Ring);
}

Kukac.prototype.shrink = function(){
    var self = this;

    if(self.rings.length>1)
        self.rings.pop();
}

Kukac.prototype.getRings = function(){
    return self.rings;
}

// Ring
function Ring(){
    var self = this;
    self.radius = 5;
    self.setPosition({x:0, y:0});
}

Ring.prototype.setPosition = function(pos){
    this.position = pos;
}

Ring.prototype.getPosition = function(){
    return this.position;
}

Ring.prototype.draw = function(ctx){
    var self = this;
    ctx.beginPath();
    ctx.arc(self.position.x, self.position.y, self.radius, 0, 2*Math.PI);
    ctx.fill();
}

