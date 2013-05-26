var socket = io.connect('http://localhost');
socket.on('news', function (data) {
    console.log(data);
    socket.emit('my other event', { my: 'data' });
});

var game = new Game();

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
    },

    /* game logic loop */
    onStep: function(delta, time) {
        game.step(keysPressed, mouse);
    },

    /* rendering loop */
    onRender: function(delta, time) {
        game.render(this.cq, keysPressed, mouse);
    },

    /* window resize */
    onResize: function(width, height) {
        console.log(this);
        /* resize canvas with window */
        // this.cq.canvas.width = width;
        // this.cq.canvas.height = height;
        //change camera transform
        game.camera.resize(width, height);
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
