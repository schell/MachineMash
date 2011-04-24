//
//  MachineMashModel.h
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>
#import "Renderer.h"
#import "Level.h"

@interface MachineMashModel : NSObject <UIAccelerometerDelegate> {
    b2World* world;
    Level* level;
    CGPoint acceleration;
    BOOL paused;
}
+ (MachineMashModel*)sharedModel;
- (void)setGLESAPI:(int)api;
- (void)step;
- (b2World*)world;
- (Level*)level;
- (CGFloat)accelerationAngle;
- (void)togglePause;
@end
