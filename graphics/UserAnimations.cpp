//
//  UserAnimations.cpp
//  MachineMash
//
//  Created by Schell Scivally on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UserAnimations.h"
#include "Geometry.h"

UserAnimations UserAnimations::sharedInstance() {
    static UserAnimations __shared;
    return __shared;
}

BlitAnimation* createTire1() {
    BlitAnimation* blitimation = BlitAnimation::create(0.12);
    
    Texture animations = Texture::fetchByName("animation");
    if (!animations.isValid()) {
        return (BlitAnimation*)0;
    }
    
    for (int i = 0; i < 3; i++) {
        std::vector<GLfloat> verts = Geometry::rectangle(0, 0, 1.0, 1.0);
        std::vector<GLfloat> coords = Geometry::texRect(0.25*i+0.125, 0.125, 0.25, 0.25);
        GLushort indexes[] = {0, 1, 2, 3};
        std::vector<GLushort> indices(indexes,indexes+4);
        Blit frame(verts, coords, indices, animations);
        blitimation->addBlit(frame);
        blitimation->name = "tire1";
    }
    return blitimation;
}

BlitAnimation* UserAnimations::tire1() {
    BlitAnimation* tire1 = BlitAnimation::fetchByName("tire1");
    if (tire1 == (BlitAnimation*)0) {
        tire1 = createTire1();
    }
    return tire1;
}