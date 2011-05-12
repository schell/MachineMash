//
//  Level.h
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>
#import "Machine.h"

#define PTM_RATIO 32

@interface Level : NSObject {
    b2World* world;
    Machine* player;
}

- (id)initWithWorld:(b2World*)aworld;
- (Machine*)createPlayer;
- (void)setup;
- (void)step;
- (BOOL)orientationFollowsActualGravity;
- (BOOL)handlesSteppingWorld;
- (b2Vec2)gravityVector;
- (void)touchesBegan:(NSSet*)touches inView:(UIView*)view;
- (void)touchesMoved:(NSSet*)touches inView:(UIView*)view;
- (void)touchesEnded:(NSSet*)touches inView:(UIView*)view;
@property (readwrite,assign) CGFloat accelerationAngle;
@end
