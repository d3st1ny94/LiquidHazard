//
//  CollisionCallback.hpp
//  LiquidHazard
//
//  Created by adan de la pena on 7/8/16.
//  Copyright © 2016 White Widget Limited. All rights reserved.
//

#ifndef CollisionCallback_hpp
#define CollisionCallback_hpp

#import "Box2D.h"
#include <stdio.h>
class CollisionCallback : public b2ContactListener {
    virtual void BeginContact(b2ParticleSystem* particleSystem,
                              b2ParticleBodyContact* particleBodyContact);
    virtual void EndContact(b2Fixture* fixture,
                            b2ParticleSystem* particleSystem, int32 index);
};
#endif /* CollisionCallback_hpp */
