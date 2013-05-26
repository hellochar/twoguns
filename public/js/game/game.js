function Game() {
    var world = this.world = new b2World(
            new b2Vec2(0, 10)    //gravity
            ,  true                 //allow sleep
            );

    this.camera = new Camera(this);

    var fixDef = new b2FixtureDef;
    fixDef.density = 1.0;
    fixDef.friction = 0.5;
    fixDef.restitution = 0.2;

    var bodyDef = new b2BodyDef;


    var worldWidth = 20,
        worldHeight = 20;

    //create bounding box
    bodyDef.type = b2Body.b2_staticBody;
    fixDef.shape = new b2PolygonShape;

    //create top/bottom
    fixDef.shape.SetAsBox(worldWidth, 2);
    bodyDef.position.Set(0, -( worldHeight/2 + 1 ) );
    world.CreateBody(bodyDef).CreateFixture(fixDef);
    bodyDef.position.Set(0, +( worldHeight/2 + 1 ) );
    world.CreateBody(bodyDef).CreateFixture(fixDef);

    //create left/right
    fixDef.shape.SetAsBox(2, worldHeight);
    bodyDef.position.Set(-( worldWidth/2 + 1 ), 0);
    world.CreateBody(bodyDef).CreateFixture(fixDef);
    bodyDef.position.Set(+( worldWidth/2 + 1 ), 0);
    world.CreateBody(bodyDef).CreateFixture(fixDef);

    //create you
    this.you = (function() {
        bodyDef.type = b2Body.b2_dynamicBody;
        fixDef.shape = new b2PolygonShape;
        fixDef.shape.SetAsBox( .2, 1.7 );

        bodyDef.position.Set(0, -worldHeight/2 + 1.7 / 2);

        var body = world.CreateBody(bodyDef);
        body.CreateFixture(fixDef);

        return body;
    })();
}

Game.prototype.step = function(keysPressed, mouse) {
    //todo make player respond to input
    this.world.Step(1 / 60, 10, 10);
    this.world.ClearForces();
}

Game.prototype.render = function(cq, keysPressed, mouse) {
    this.camera.lookAt(this.you.GetPosition());
    this.camera.translateScreen(new b2Vec2(mouse.x - cq.canvas.width/2, mouse.y - cq.canvas.height/2));
    this.camera.render(cq);
}


function Camera(game) {
    this.center = new b2Vec2; //world coordinates
    this.scale = 30; //pixel distances -> world distances
    this.game = game;

    //setup debug draw
    this.debugDraw = new b2DebugDraw();
    this.debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
    game.world.SetDebugDraw(this.debugDraw);
}

Camera.prototype.lookAt = function(center) {
    this.center.SetV(center);
}

Camera.prototype.translate = function(delta) {
    this.center.Add(delta);
}

Camera.prototype.translateScreen = function(delta) {
    delta.Multiply(1 / this.scale);
    this.center.Add(delta);
}

Camera.prototype.resize = function(width, height) {
}

Camera.prototype.render = function(cq) {
    this.debugDraw.SetSprite(cq.context);
    this.debugDraw.SetDrawScale(this.scale);
    this.debugDraw.SetFillAlpha(0.5);
    this.debugDraw.SetLineThickness(0.05);

    cq.clear();
    cq.context.save();

    cq.translate(cq.canvas.width/2 - this.center.x * this.scale
               , cq.canvas.height/2 - this.center.y * this.scale
               );

    this.game.world.DrawDebugData();

    cq.context.restore();
}
