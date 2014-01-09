define ['box2d'], (Box2D) ->
  b2 = {}

  b2.Vec2 = Box2D.Common.Math.b2Vec2
  b2.AABB = Box2D.Collision.b2AABB
  b2.BodyDef = Box2D.Dynamics.b2BodyDef
  b2.Body = Box2D.Dynamics.b2Body
  b2.FixtureDef = Box2D.Dynamics.b2FixtureDef
  b2.Fixture = Box2D.Dynamics.b2Fixture
  b2.World = Box2D.Dynamics.b2World
  b2.MassData = Box2D.Collision.Shapes.b2MassData
  b2.PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
  b2.CircleShape = Box2D.Collision.Shapes.b2CircleShape
  b2.DebugDraw = Box2D.Dynamics.b2DebugDraw
  b2.MouseJointDef =  Box2D.Dynamics.Joints.b2MouseJointDef
  b2.MassData = Box2D.Collision.Shapes.b2MassData
  b2.Shape = Box2D.Collision.Shapes.b2Shape
  b2.Math = Box2D.Common.Math.b2Math
  b2.Settings = Box2D.Common.b2Settings
  b2.WorldManifold = Box2D.Collision.b2WorldManifold

  b2
