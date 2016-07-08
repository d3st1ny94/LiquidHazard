//
//  LiquidFun.mm
//  LiquidHazard
//
//  Created by adan de la pena on 6/20/16.
//  Copyright © 2016 adan de la pena. All rights reserved.
//

#import "LiquidFun.h"
#import "Box2D.h"
#import "Box2D/Collision/CollisionCallback.hpp"

static b2World *world;
CollisionCallback *contactListener;

@implementation LiquidFun

+ (void)createWorldWithGravity:(Vector2D)gravity {
  world = new b2World(b2Vec2(gravity.x, gravity.y));
}
+ (void)resetWorldWithGravity:(Vector2D)gravity{
    if(world)
    {
        delete world;
    }
    world = new b2World(b2Vec2(gravity.x, gravity.y));
}
+ (void *)createBoxObstacleWithSizeAndOrigin:(Size2D)size origin:(Vector2D)origin{
    // create the body
    b2BodyDef bodyDef;
    bodyDef.position.Set(origin.x, origin.y);
    b2Body *body = world->CreateBody(&bodyDef);
    
    // create edge
    b2PolygonShape shape;
    shape.SetAsBox(size.width, size.height);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    body->CreateFixture(&fixtureDef);
    //return body //returning in case we wana use it further
    return body;
}
+ (void *)createGoalWithSizeAndOrigin:(Size2D)size origin:(Vector2D)origin{
    // create the body
    b2BodyDef bodyDef;
    bodyDef.position.Set(origin.x, origin.y);
    b2Body *body = world->CreateBody(&bodyDef);
    // create edge
    b2PolygonShape shape;
    shape.SetAsBox(size.width, size.height);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    char *usrdata = new char('w');
    fixtureDef.userData = usrdata;
    body->CreateFixture(&fixtureDef);
    contactListener = new CollisionCallback();
    contactListener -> BallIn = 0;
    world->SetContactListener(contactListener);
    //return body //returning in case we wana use it further
    return body;
}
+(int) getBallIn{
    int ret = contactListener->BallIn;
    return ret;
}
+ (void *)createParticleSystemWithRadius:(float)radius dampingStrength:(float)dampingStrength gravityScale:(float)gravityScale density:(float)density {
  b2ParticleSystemDef particleSystemDef;
  particleSystemDef.radius = radius;
  particleSystemDef.dampingStrength = dampingStrength;
  particleSystemDef.gravityScale = gravityScale;
  particleSystemDef.density = density;
  
  b2ParticleSystem *particleSystem = world->CreateParticleSystem(&particleSystemDef);
  
  return particleSystem;
}

+ (void)worldStep:(CFTimeInterval)timeStep velocityIterations:(int)velocityIterations
positionIterations:(int)positionIterations {
    world->Step(timeStep, velocityIterations, positionIterations);
}

+ (void)createParticleBoxForSystem:(void *)particleSystem position:(Vector2D)position size:(Size2D)size {
  b2PolygonShape shape;
  shape.SetAsBox(size.width * 0.5f, size.height * 0.5f);
  
  b2ParticleGroupDef particleGroupDef;
  particleGroupDef.flags = b2_waterParticle | b2_fixtureContactListenerParticle;
  particleGroupDef.position.Set(position.x, position.y);
  particleGroupDef.shape = &shape;
  
  ((b2ParticleSystem *)particleSystem)->CreateParticleGroup(particleGroupDef);
}

+ (void *)createEdgeBoxWithOrigin:(Vector2D)origin size:(Size2D)size {
    // create the body
    b2BodyDef bodyDef;
    bodyDef.position.Set(origin.x, origin.y);
    b2Body *body = world->CreateBody(&bodyDef);
    
    // create the edges of the box
    b2EdgeShape shape;
    
    // bottom
    shape.Set(b2Vec2(0, 0), b2Vec2(size.width, 0));
    body->CreateFixture(&shape, 0);
    
    // top
    shape.Set(b2Vec2(0, size.height), b2Vec2(size.width, size.height));
    body->CreateFixture(&shape, 0);
    
    // left
    shape.Set(b2Vec2(0, size.height), b2Vec2(0, 0));
    body->CreateFixture(&shape, 0);
    
    // right
    shape.Set(b2Vec2(size.width, size.height), b2Vec2(size.width, 0));
    body->CreateFixture(&shape, 0);
    
    return body;
}
+ (void *)createEdgeWithOrigin:(Vector2D)origin destination:(Vector2D)endpoint {
    // create the body
    b2BodyDef bodyDef;
    bodyDef.position.Set(origin.x, origin.y);
    b2Body *body = world->CreateBody(&bodyDef);
    
    // create edge
    b2EdgeShape shape;
    shape.Set(b2Vec2(origin.x, origin.y), b2Vec2(endpoint.x, endpoint.y));
    body->CreateFixture(&shape, 0);
    
    //return body
    return body;
}

+ (void)setParticleLimitForSystem:(void *)particleSystem maxParticles:(int)maxParticles {
    ((b2ParticleSystem *)particleSystem)->SetDestructionByAge(true);
    ((b2ParticleSystem *)particleSystem)->SetMaxParticleCount(maxParticles);
}

+ (void)setGravity:(Vector2D)gravity {
    world->SetGravity(b2Vec2(gravity.x, gravity.y));
}

+ (int)particleCountForSystem:(void *)particleSystem {
  return ((b2ParticleSystem *)particleSystem)->GetParticleCount();
}

+ (void *)particlePositionsForSystem:(void *)particleSystem {
  return ((b2ParticleSystem *)particleSystem)->GetPositionBuffer();
}

@end
