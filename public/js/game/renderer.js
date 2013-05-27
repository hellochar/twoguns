function Renderer(viewportWidth) {
    this.viewportWidth = viewportWidth;
    this.center = new b2Vec2; //world coordinates

    //setup debug draw
    this.debugDraw = new b2DebugDraw();
    this.debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
}

Renderer.prototype.lookAt = function(center) {
    this.center.SetV(center);
}

Renderer.prototype.translate = function(delta) {
    this.center.Add(delta);
}

Renderer.prototype.render = function(cq, keysPressed, mouse, game) {
    game.world.SetDebugDraw(this.debugDraw);

    var scale = cq.canvas.width / this.viewportWidth;

    /*
     * ===========translateScreen===========
     * Move the camera by the given screen coordinate offset
     *
     * must be defined inside the render method because only inside render do we have a cq
     */
    var translateScreen = function(delta) {
        delta.Multiply(1 / scale);
        this.center.Add(delta);
    }.bind(this);

    this.lookAt(game.you.GetPosition());
    translateScreen(new b2Vec2(mouse.x - cq.canvas.width/2, mouse.y - cq.canvas.height/2));

    this.debugDraw.SetSprite(cq.context);
    this.debugDraw.SetDrawScale(scale);
    this.debugDraw.SetFillAlpha(0.5);
    this.debugDraw.SetLineThickness(0.05);

    cq.clear();
    cq.context.save();

    cq.translate(cq.canvas.width/2 - this.center.x * scale
               , cq.canvas.height/2 - this.center.y * scale
               );

    game.world.DrawDebugData();

    cq.context.restore();
}

