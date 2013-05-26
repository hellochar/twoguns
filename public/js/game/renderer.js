function Renderer() {
    this.center = new b2Vec2; //world coordinates
    this.scale = 30; //pixel distances -> world distances

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

Renderer.prototype.translateScreen = function(delta) {
    delta.Multiply(1 / this.scale);
    this.center.Add(delta);
}

Renderer.prototype.render = function(cq, keysPressed, mouse, game) {
    game.world.SetDebugDraw(this.debugDraw);
    this.lookAt(game.you.GetPosition());
    this.translateScreen(new b2Vec2(mouse.x - cq.canvas.width/2, mouse.y - cq.canvas.height/2));

    this.debugDraw.SetSprite(cq.context);
    this.debugDraw.SetDrawScale(this.scale);
    this.debugDraw.SetFillAlpha(0.5);
    this.debugDraw.SetLineThickness(0.05);

    cq.clear();
    cq.context.save();

    cq.translate(cq.canvas.width/2 - this.center.x * this.scale
               , cq.canvas.height/2 - this.center.y * this.scale
               );

    game.world.DrawDebugData();

    cq.context.restore();
}

