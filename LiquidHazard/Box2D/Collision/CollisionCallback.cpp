//
//  CollisionCallback.cpp
//  LiquidHazard
//
//  Created by adan de la pena on 7/8/16.
//  Copyright © 2016 White Widget Limited. All rights reserved.#import "Box2D.h"

//

#include "CollisionCallback.hpp"
void CollisionCallback::BeginContact(b2ParticleSystem* particleSystem,
                                     b2ParticleBodyContact* particleBodyContact) {
    
    /*check if fixture was our goal, then remove particle */
    char *ttype = (char *) particleBodyContact->fixture->GetUserData();
        if( ttype )
        if( *ttype == 'w'){
            //the fixture was our goal we can proceed to remove th e particle
            particleSystem->DestroyParticle(particleBodyContact->index);
            BallIn++;
        }
}
void CollisionCallback::EndContact(b2Fixture* fixture,
                                   b2ParticleSystem* particleSystem, int32 index) {
    //play splash sound or handle other post collision actions

}
