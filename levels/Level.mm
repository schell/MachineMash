//
//  Level.m
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import "Level.h"


@implementation Level
@synthesize accelerationAngle;

#pragma -
#pragma Lifecycle


- (id)initWithWorld:(b2World*)aworld {
    self = [super init];
    world = aworld;
    [self setup];
    accelerationAngle = 0;
    return self;
}

- (void)dealloc {
    world = NULL;
    [super dealloc];
}

#pragma -
#pragma Setup

- (void)setup {
    float bottom = -10.0;
    float wide = 15.0;
    player = [self createPlayer];
    b2BodyDef bd;
    b2Body* ground = world->CreateBody(&bd);
    b2PolygonShape edge;
    edge.SetAsEdge(b2Vec2(-wide, bottom), b2Vec2(wide, bottom));
    ground->CreateFixture(&edge, 0.0);
    edge.SetAsEdge(b2Vec2(wide, bottom), b2Vec2(wide+0.2, bottom+1.0));
    ground->CreateFixture(&edge, 0.0);
    edge.SetAsEdge(b2Vec2(-wide, bottom), b2Vec2(-wide, bottom+1.0));
    ground->CreateFixture(&edge, 0.0);
}

- (Machine*)createPlayer {
    return [[Machine alloc] initWithWorld:world];
}

#pragma -
#pragma Settings

- (BOOL)orientationFollowsActualGravity {
    return YES;
}

- (BOOL)handlesSteppingWorld {
    return NO;
}

- (b2Vec2)gravityVector {
    const float gravityScalar = -10.0;
    return b2Vec2(0.0, gravityScalar);
}

#pragma -
#pragma Step

- (void)step {
    
}

#pragma -
#pragma Touches

- (void)touchesBegan:(NSSet*)touches inView:(UIView *)view {
    NSLog(@"%s",__FUNCTION__);
}
- (void)touchesMoved:(NSSet*)touches inView:(UIView *)view {
    NSLog(@"%s",__FUNCTION__);
}
- (void)touchesEnded:(NSSet*)touches inView:(UIView *)view {
    NSLog(@"%s",__FUNCTION__);
}

@end
