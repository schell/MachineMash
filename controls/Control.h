//
//  Control.h
//  MachineMash
//
//  Created by Schell Scivally on 4/24/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

typedef enum {
    ControlStateOff,
    ControlStateOn
} ControlState;

class Control {
public:
    b2Vec2 position;
    ControlState controlState;
    
    Control();
    ~Control();
    void setPosition(float x, float y);
    void setState(ControlState state);
};
