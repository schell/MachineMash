//
//  Renderer.h
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Box2D/Box2D.h>

#import "GLESDebugDraw.h"
#import "GLProgram.h"
#import "GLMath.h"

@interface Renderer : NSObject {
    BOOL GLisInitialized;
    mat4 preMatrix;
    mat4 postMatrix;
    CGFloat zoomScale;
}
+ (void)use:(Renderer*)shared;
+ (Renderer*)sharedRenderer;
+ (Renderer*)ES1Renderer;
+ (Renderer*)ES2Renderer;
- (void)setFlags;
- (BOOL)loadShaders;
- (void)setScreenWidth:(float)width andHeight:(float)height;
- (void)render:(b2World*)world;
- (float)screenWidth;
- (float)screenHeight;
- (mat4*)preMultiplyMatrix;
- (mat4*)postMultiplyMatrix;
- (void)setZoomScale:(CGFloat)zoom;
- (CGFloat)zoomScale;
@property (readwrite,assign) GLESDebugDraw* internalRenderer;
@property (readwrite,assign) uint api;
@property (readwrite,retain) GLProgram* program;
@end