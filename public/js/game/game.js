//model of the game
//
//  there is a physics world, with objects etc.
//  there are players within the physics world
//  there are bullets owned by players
//  there is a win/lose condition

function Game(width, height, gridSize) {
    this.width = width;
    this.height = height;
    this.gridSize = gridSize;

    var world = this.world = new b2World(
            new b2Vec2(0, 10)    //gravity
            ,  true                 //allow sleep
            );

    var fixDef = new b2FixtureDef;
    fixDef.density = 1.0;
    fixDef.friction = 0.5;
    fixDef.restitution = 0.2;

    var bodyDef = new b2BodyDef;


    //create bounding box
    bodyDef.type = b2Body.b2_staticBody;
    fixDef.shape = new b2PolygonShape;

    //create top/bottom
    fixDef.shape.SetAsBox(width, 2);
    bodyDef.position.Set(0, -( height/2 + 1 ) );
    world.CreateBody(bodyDef).CreateFixture(fixDef);
    bodyDef.position.Set(0, +( height/2 + 1 ) );
    world.CreateBody(bodyDef).CreateFixture(fixDef);

    //create left/right
    fixDef.shape.SetAsBox(2, height);
    bodyDef.position.Set(-( width/2 + 1 ), 0);
    world.CreateBody(bodyDef).CreateFixture(fixDef);
    bodyDef.position.Set(+( width/2 + 1 ), 0);
    world.CreateBody(bodyDef).CreateFixture(fixDef);

    //create you
    this.you = (function() {
        bodyDef.type = b2Body.b2_dynamicBody;
        fixDef.shape = new b2PolygonShape;
        fixDef.shape.SetAsBox( .2, 1.7 );

        bodyDef.position.Set(0, -height/2 + 1.7 / 2);

        var body = world.CreateBody(bodyDef);
        body.CreateFixture(fixDef);

        return body;
    })();

    //create platform boxes
}

Game.prototype.step = function(keysPressed, mouse) {
    //todo make player respond to input
    this.world.Step(1 / 60, 10, 10);
    this.world.ClearForces();
}
