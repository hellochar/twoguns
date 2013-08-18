var require = {
    baseUrl: "js/game",
    paths: {
        jquery: ['//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min', '../vendor/jquery-1.9.1.min'],
        'socket.io': ['/socket.io/socket.io'],
        box2d: ['../vendor/Box2dWeb-2.1.a.3.min'],
        b2: 'b2',
        canvasquery: ['../vendor/canvasquery'],
        noise: ['../vendor/noise'],
        stats: ['../vendor/stats']
    },
    shim: {
        box2d: {
            exports: 'Box2D'
        },
        noise: {
            exports: 'ClassicalNoise'
        },
        stats: {
            exports: 'Stats'
        }
    }
};
