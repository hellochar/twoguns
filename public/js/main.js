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

var framework = {

    setup : function() {
        this.cq = cq().framework(this, this);
        this.cq.appendTo("body");
        this.game = new Game(this.cq);
    },

    /* game logic loop */
    onStep: function(delta, time) {
        this.game.step(keysPressed, mouse);
    },

    /* rendering loop */
    onRender: function(delta, time) {
        this.game.render(this.cq, keysPressed, mouse);
    },

    /* window resize */
    onResize: function(width, height) {
        console.log(this);
        /* resize canvas with window */
        //change camera transform
        if(this.game) {
            this.game.cq.canvas.width = width;
            this.game.cq.canvas.height = height;
            this.game.renderer.resize(width, height);
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
