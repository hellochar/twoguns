(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['jquery', 'underscore', 'b2', 'utils', 'game/entity/bullet', 'game/render/scoreboard', 'game/render/image_cache'], function($, _, b2, Utils, Bullet, Scoreboard, ImageCache) {
    var Renderer;
    Renderer = (function() {
      function Renderer(viewportWidth, game, cq) {
        this.viewportWidth = viewportWidth;
        this.game = game;
        this.cq = cq;
        this.drawSolidPolygon = __bind(this.drawSolidPolygon, this);
        this.drawSolidCircle = __bind(this.drawSolidCircle, this);
        this.drawShape = __bind(this.drawShape, this);
        this.drawBodyDefault = __bind(this.drawBodyDefault, this);
        this.drawBody = __bind(this.drawBody, this);
        this.renderWorld = __bind(this.renderWorld, this);
        this.render = __bind(this.render, this);
        this.visibleAABB = __bind(this.visibleAABB, this);
        this.scale = __bind(this.scale, this);
        this.worldVec2 = __bind(this.worldVec2, this);
        this.translate = __bind(this.translate, this);
        this.lookAt = __bind(this.lookAt, this);
        this.center = new b2.Vec2();
        this.scoreboard = new Scoreboard(this.game);
        $(this.cq.canvas).css('background-color', 'black');
      }

      Renderer.prototype.lookAt = function(center) {
        return this.center.SetV(center);
      };

      Renderer.prototype.translate = function(delta) {
        return this.center.Add(delta);
      };

      Renderer.prototype.worldVec2 = function(screenVec2) {
        var worldVec2;
        worldVec2 = screenVec2.Copy();
        worldVec2.x -= this.cq.canvas.width / 2;
        worldVec2.y -= this.cq.canvas.height / 2;
        worldVec2.Multiply(1 / this.scale());
        worldVec2.Add(this.center);
        return worldVec2;
      };

      Renderer.prototype.scale = function() {
        return this.cq.canvas.width / this.viewportWidth;
      };

      Renderer.prototype.visibleAABB = function() {
        var aabb;
        aabb = new b2.AABB();
        aabb.lowerBound = this.worldVec2(new b2.Vec2(0, 0));
        aabb.upperBound = this.worldVec2(new b2.Vec2(this.cq.canvas.width, this.cq.canvas.height));
        return aabb;
      };

      Renderer.prototype.render = function(mx, my) {
        this.cq.clear();
        this.renderWorld(mx, my);
        return $(this).trigger('rendered');
      };

      Renderer.prototype.renderWorld = function(mx, my) {
        var body, isect, point, _i, _j, _len, _len1, _ref, _ref1;
        this.cq.save();
        this.game.youPlayer.lookAt(this, mx, my);
        this.cq.translate(this.cq.canvas.width / 2 - this.center.x * this.scale(), this.cq.canvas.height / 2 - this.center.y * this.scale()).scale(this.scale(), this.scale()).lineWidth(1 / this.scale());
        this.cq.fillStyle("white").globalCompositeOperation("source-over");
        this.cq.beginPath();
        _ref = this.game.youPlayer.getVisionPoly();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          this.cq.lineTo(point.x, point.y);
        }
        this.cq.fill();
        this.cq.context.globalCompositeOperation = "source-atop";
        this.cq.context.save();
        this.cq.scale(.2, .2);
        this.cq.drawImage(ImageCache.get('img/bg.jpg'), -400, -920);
        this.cq.context.restore();
        this.cq.globalCompositeOperation("destination-over");
        this.cq.context.save();
        this.cq.scale(.2, .2);
        this.cq.drawImage(ImageCache.get('img/bg-novision.jpg'), -400, -920);
        this.cq.context.restore();
        this.cq.globalCompositeOperation("source-over");
        _ref1 = this.game.getBodiesInAABB(this.visibleAABB());
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          body = _ref1[_j];
          if (body.GetUserData().isVisible(this.game.youPlayer)) {
            this.drawBody(body);
          }
        }
        if (this.game.youPlayer.body) {
          isect = this.game.rayIntersect(this.game.youPlayer.body.GetWorldCenter(), this.game.youPlayer.direction, (function(fixture) {
            return !(fixture.GetBody().GetUserData() instanceof Bullet);
          }), 100);
        }
        if (isect) {
          this.cq.fillStyle("red").beginPath().circle(isect.point.x, isect.point.y, 0.035).fill();
          this.cq.strokeStyle("rgba(255, 0, 0, 0.3)").beginPath().moveTo(this.game.youPlayer.body.GetWorldCenter().x, this.game.youPlayer.body.GetWorldCenter().y).lineTo(isect.point.x, isect.point.y).stroke();
        }
        return this.cq.restore();
      };

      Renderer.prototype.drawBody = function(body) {
        var _ref, _ref1,
          _this = this;
        if ((_ref = body.GetUserData()) != null ? _ref.draw : void 0) {
          return (_ref1 = body.GetUserData()) != null ? _ref1.draw(this, function() {
            return _this.drawBodyDefault(body);
          }) : void 0;
        } else {
          return this.drawBodyDefault(body);
        }
      };

      Renderer.prototype.drawBodyDefault = function(body) {
        var color, fixture, shape, xf, _i, _len, _ref, _ref1, _results;
        xf = body.m_xf;
        color = ((_ref = body.GetUserData()) != null ? _ref.color() : void 0) || "black";
        _ref1 = this.game.getFixturesOf(body);
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          fixture = _ref1[_i];
          shape = fixture.GetShape();
          _results.push(this.drawShape(shape, xf, color));
        }
        return _results;
      };

      Renderer.prototype.drawShape = function(shape, xf, color) {
        var axis, center, circle, edge, radius, v, vertices;
        switch (shape.m_type) {
          case b2.Shape.e_circleShape:
            circle = shape;
            center = b2.Math.MulX(xf, circle.m_p);
            radius = circle.m_radius;
            axis = xf.R.col1;
            return this.drawSolidCircle(center, radius, axis, color);
          case b2.Shape.e_polygonShape:
            vertices = (function() {
              var _i, _len, _ref, _results;
              _ref = shape.GetVertices();
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                v = _ref[_i];
                _results.push(b2.Math.MulX(xf, v));
              }
              return _results;
            })();
            return this.drawSolidPolygon(vertices, color);
          case b2.Shape.e_edgeShape:
            edge = shape;
            return this.drawSegment(b2.Math.MulX(xf, edge.GetVertex1()), b2.Math.MulX(xf, edge.GetVertex2()), color);
        }
      };

      Renderer.prototype.drawSolidCircle = function(center, radius, axis, color) {
        var cx, cy, drawScale, s;
        if (!radius) {
          return;
        }
        s = this.cq.context;
        drawScale = 1;
        cx = center.x * drawScale;
        cy = center.y * drawScale;
        s.moveTo(0, 0);
        s.beginPath();
        s.strokeStyle = color;
        s.fillStyle = color;
        s.arc(cx, cy, radius * drawScale, 0, Math.PI * 2, true);
        s.moveTo(cx, cy);
        s.lineTo((center.x + axis.x * radius) * drawScale, (center.y + axis.y * radius) * drawScale);
        s.closePath();
        s.fill();
        return s.stroke();
      };

      Renderer.prototype.drawSolidPolygon = function(vertices, color) {
        var s, v, _i, _len, _ref;
        s = this.cq.context;
        s.beginPath();
        s.strokeStyle = color;
        s.fillStyle = color;
        s.moveTo(vertices[0].x, vertices[0].y);
        _ref = vertices.slice(1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          s.lineTo(v.x, v.y);
        }
        s.lineTo(vertices[0].x, vertices[0].y);
        s.closePath();
        s.fill();
        return s.stroke();
      };

      return Renderer;

    })();
    return Renderer;
  });

}).call(this);
