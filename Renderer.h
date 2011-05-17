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
#import "Graphics.h"

#pragma mark -
#pragma mark Renderer

@interface Renderer : NSObject {
    BOOL GLisInitialized;
    Matrix preMatrix;
    Matrix postMatrix;
    CGFloat zoomScale;
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
- (void)drawUserInterface;
- (float)screenWidth;
- (float)screenHeight;
- (Matrix*)preMultiplyMatrix;
- (Matrix*)postMultiplyMatrix;
- (void)setZoomScale:(CGFloat)zoom;
- (CGFloat)zoomScale;
- (void)loadTexture:(NSString*)imageName;
@property (readwrite,assign) GLESDebugDraw* internalRenderer;
@property (readwrite,assign) uint api;
@end