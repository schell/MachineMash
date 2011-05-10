//
//  LevelWithRadialGravity.h
//  MachineMash
//
//  Created by Schell Scivally on 4/5/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelWithRadialGravity : Level {
    mat4 matrix;
    b2Body* actor;
    b2Body* planet;
}

@end
