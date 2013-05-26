function Camera(game, viewportWidth) {
    this.viewportWidth = viewportWidth;
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

