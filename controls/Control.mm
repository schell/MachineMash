//
//  Control.m
//  MachineMash
//
//  Created by Schell Scivally on 4/24/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import "Control.h"

#pragma -
#pragma Control

Control::Control() {
    this->position = b2Vec2(0.0, 0.0);
    this->controlState = ControlStateOff;
}

Control::~Control() {
    
}

void Control::setPosition(float x, float y) {
    this->position.x = x;
    this->position.y = y;
}

void Control::setState(ControlState state) {
    this->controlState = state;
    printf("\nControl::setState()\n");
}