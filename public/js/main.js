var socket = io.connect('http://localhost');
socket.on('news', function (data) {
    console.log(data);
    socket.emit('my other event', { my: 'data' });
});

var keysPressed = {}; //key1: true, key2: true, key3: true
var mouse = {
    x : 0,
    y : 0, //pixel coordinates of mouse relative to top-left of canvas
    button : -1, //-1,0,1,2 === not-pressed, left, middle, right
}

//The framework hooks the renderer and game model together, and also handles events
//Events make the core of the framework. You can think of the game as just being a bunch of events happening, and responding accordingly
var framework = {

    setup : function() {
        this.cq = cq().framework(this, this);
        this.cq.appendTo("body");
        mouse.x = this.cq.canvas.width/2;
        mouse.y = this.cq.canvas.height/2;
        this.game = new Game(80, 20, 1);
        this.renderer = new Renderer(20);
    },

    /* game logic loop */
    onStep: function(delta, time) {
        this.game.step(keysPressed, mouse);
    },

    /* rendering loop */
    onRender: function(delta, time) {
        this.renderer.render(this.cq, keysPressed, mouse, this.game);
    },

    /* window resize */
    onResize: function(width, height) {
        /* resize canvas with window */
        //change camera transform
        if(this.cq) {
            this.cq.canvas.width = width;
            this.cq.canvas.height = height;
        }
    },

    /* mouse and touch events */
    onMouseDown: function(x, y, button) {
        mouse.button = button;
        mouse.x = x;
        mouse.y = y;
    },
    onMouseUp: function(x, y, button) {
        mouse.button = -1;
        mouse.x = x;
        mouse.y = y;
    },
    onMouseMove: function(x, y) {
        mouse.x = x;
        mouse.y = y;
    },

    /* keyboard events */
    onKeyDown: function(key) {
        keysPressed[key] = true;
    },
    onKeyUp: function(key) {
        delete keysPressed[key];
    },
};

framework.setup();
