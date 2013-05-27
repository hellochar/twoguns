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
    fixDef.shape.SetAsBox(width/2, 1);
    bodyDef.position.Set(0, -( height/2 + 1 ) );
    world.CreateBody(bodyDef).CreateFixture(fixDef);
    bodyDef.position.Set(0, +( height/2 + 1 ) );
    world.CreateBody(bodyDef).CreateFixture(fixDef);

    //create left/right
    fixDef.shape.SetAsBox(1, height/2);
    bodyDef.position.Set(-( width/2 + 1 ), 0);
    world.CreateBody(bodyDef).CreateFixture(fixDef);
    bodyDef.position.Set(+( width/2 + 1 ), 0);
    world.CreateBody(bodyDef).CreateFixture(fixDef);

    //create you
    this.you = (function() {
        var bodyDef = new b2BodyDef;
        bodyDef.type = b2Body.b2_dynamicBody;
        bodyDef.position.Set(0, 0);
        bodyDef.fixedRotation = true;

        var body = world.CreateBody(bodyDef);

        var fixDef = new b2FixtureDef;

        // main body/torso
        fixDef.density = 1.0;
        fixDef.friction = 0.8;
        fixDef.restitution = -10;
        fixDef.shape = new b2PolygonShape;
        fixDef.shape.SetAsBox( .2 / 2, 1.7 / 2 );

        body.CreateFixture(fixDef);

        // feet sensor
        fixDef.isSensor = true;
        fixDef.shape.SetAsEdge(new b2Vec2( -.2 / 2, 1.7 / 2), new b2Vec2( +.2 / 2, 1.7 / 2 ) );
        body.feet = body.CreateFixture(fixDef);

        return body;
    })();

    //create platform boxes
    bodyDef.position.Set(0, 0);
    bodyDef.type = b2Body.b2_staticBody;
    this.platformBody = world.CreateBody(bodyDef);
    // platformBody.SetUserData({ class : 'platform' });

    this.noise = new ClassicalNoise();

    /*
     * between 1 and 2 produces a dense maze-like structure (it seems that any 1 < n < 2 has the same characteristics)
     * exactly 2 produces quite thin lines, somewhat sparse
     * after 2 the usual noisey-ness comes into play
     *
     */
    var noiseScalar = 3;

    for(var x = -width/2; x < width/2; x += gridSize) {
        for(var y = -height/2; y < height/2; y += gridSize) {
            if((this.noise.noise(x/noiseScalar, y/noiseScalar, 0) + 1) / 2 < .5) {
                fixDef.shape.SetAsBox(gridSize / 2, gridSize / 2);
                bodyDef.position.Set(x + gridSize / 2, y + gridSize / 2);
                world.CreateBody(bodyDef).CreateFixture(fixDef);
                //query neighbors, create contacts
            }
        }
    }
}

Game.prototype.step = function(keysPressed, mouse) {
    //todo make player respond to input

    // var canJump = (function() {
    //     for(var ce = this.you.GetContactList(); ce; ce = ce.next) {
    //         var c = ce.contact;
    //         if(c.
    //     }
    // })();

    if('w' in keysPressed) {
        this.you.ApplyImpulse(new b2Vec2(0, -1), this.you.GetWorldCenter());
    }
    if('a' in keysPressed) {
        this.you.ApplyImpulse(new b2Vec2(-1, 0), this.you.GetWorldCenter());
    }
    if('d' in keysPressed) {
        this.you.ApplyImpulse(new b2Vec2(1, 0), this.you.GetWorldCenter());
    }
    this.world.Step(1 / 30, 10, 10);
    this.world.ClearForces();
}
