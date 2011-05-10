//
//  Sprite.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Sprite.h"

#pragma -
#pragma Sprite

Sprite::Sprite() {
    mat4LoadIdentity(&this->matrix);
    this->alpha = 1.0;
}

Sprite::~Sprite() {
    
}

void Sprite::draw() {
    printf("Sprite::draw()");
}