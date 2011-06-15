//
//  BlitAnimation.cpp
//  MachineMash
//
//  Created by Schell Scivally on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "BlitAnimation.h"
#include <sys/time.h>
#include <cmath>

std::vector<BlitAnimation> BlitAnimation::__animations;

BlitAnimation::BlitAnimation(float secondsPerBlit):secondsPerBlit(secondsPerBlit),mode(GL_TRIANGLE_FAN),frame(0) {}

void BlitAnimation::addBlit(Blit blit) {
    this->blits.push_back(blit);
}

void BlitAnimation::addBlit(GLuint vao, Texture texture) {
    Blit blit(vao, texture);
    this->addBlit(blit);
}

void BlitAnimation::addBlit(std::vector<GLfloat> verts, std::vector<GLfloat> coords, std::vector<GLushort> indices, Texture texture) {
    Blit blit(verts, coords, indices, texture);
    this->addBlit(blit);
}

void BlitAnimation::draw() {
    this->draw(this->mode);
}

long double start = 0;
long double tv2ld(timeval tv) {
    return tv.tv_sec + tv.tv_usec/1000000.0;
}

clock_t BlitAnimation::currentBlit() {
    if (!start) {
        timeval tv;
        gettimeofday(&tv, NULL);
        start = tv2ld(tv);
    }
    long double endWait = start + this->secondsPerBlit;
    timeval tv;
    gettimeofday(&tv, NULL);
    long double now = tv2ld(tv);
    if (now > endWait) {
        this->frame = ++(this->frame)%this->blits.size();
        start = endWait;
    }
    return this->frame;
}

void BlitAnimation::draw(GLenum mode) {
    this->mode = mode;
    this->blits.at(this->currentBlit()).draw(this->mode);
}

BlitAnimation* BlitAnimation::create(float secondsPerBlit) {
    size_t index = BlitAnimation::__animations.size();
    BlitAnimation::__animations.push_back(BlitAnimation(secondsPerBlit));
    return &BlitAnimation::__animations[index];
}

void BlitAnimation::step() {
    std::vector<BlitAnimation>::iterator it = BlitAnimation::__animations.begin();
    for (; it < BlitAnimation::__animations.end(); it++) {
        (*it).draw();
    }
}

BlitAnimation* BlitAnimation::fetchByName(std::string name) {
    printf("looking for %s\n",name.c_str());
    std::vector<BlitAnimation>::iterator it = BlitAnimation::__animations.begin();
    for (; it < BlitAnimation::__animations.end(); it++) {
        std::string itname = (*it).name;
        printf("checking %s\n",itname.c_str());
        if(itname == name) {
            return &(*it);
        }
    }
    return (BlitAnimation*)0;
}