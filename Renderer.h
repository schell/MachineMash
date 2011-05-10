//
//  Renderer.h
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Box2D/Box2D.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import "GLESDebugDraw.h"
#import "GLProgram.h"
#import "GLMath.h"
#import "SSGL.h"

#pragma mark -
#pragma mark Renderer

@interface Renderer : NSObject {
    BOOL GLisInitialized;
    mat4 preMatrix;
    mat4 postMatrix;
    CGFloat zoomScale;
    spritesheet* sheets;
    unsigned int numberOfTextures;
}
+ (void)use:(Renderer*)shared;
+ (Renderer*)sharedRenderer;
+ (Renderer*)ES1Renderer;
+ (Renderer*)ES2Renderer;
- (BOOL)loadTextures;
- (BOOL)loadShaders;
- (void)setScreenWidth:(float)width andHeight:(float)height;
- (void)render:(b2World*)world;
- (void)drawTexturedGeomap:(geomap*)geom;
- (void)drawUserInterface;
- (float)screenWidth;
- (float)screenHeight;
- (mat4*)preMultiplyMatrix;
- (mat4*)postMultiplyMatrix;
- (void)setZoomScale:(CGFloat)zoom;
- (CGFloat)zoomScale;
- (spritesheet)loadTexture:(NSString*)imageName;
@property (readwrite,assign) GLESDebugDraw* internalRenderer;
@property (readwrite,assign) uint api;
@property (readwrite,retain) GLProgram* program;
@end