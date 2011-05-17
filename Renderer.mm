//
//  Renderer.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import <math.h>
#import <cstdlib>
#include <vector>
#import "Renderer.h"
#import "MachineMashModel.h"
#include "DrawableUserData.h"

#define ZOOM_MIN 2.0
#define ZOOM_MAX 60.0

@interface Renderer (PrivateMethods)
- (void)drawScene;
@end

#pragma mark -
#pragma mark RENDERER

@implementation Renderer
@synthesize internalRenderer, api;

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    self = [super init];
    GLisInitialized = NO;
    zoomScale = ZOOM_MIN + (ZOOM_MAX - ZOOM_MIN)/2;   
    Utilities::applicationBundleLocation = std::string([[[NSBundle mainBundle] bundlePath] UTF8String]);
    return self;
}

- (void)dealloc {
    delete internalRenderer;
    [super dealloc];
}


#pragma mark -
#pragma mark Class Methods

Renderer* __sharedRenderer = nil;
+ (void)use:(Renderer*)renderer {
    __sharedRenderer = renderer;
}

+ (Renderer*)sharedRenderer {
    if (__sharedRenderer == nil) {
        __sharedRenderer = [Renderer ES2Renderer];
    }
    return __sharedRenderer;
}

Renderer* __es1Renderer = nil;
Renderer* __es2Renderer = nil;
+ (Renderer*)ES1Renderer {
    if (__es2Renderer != nil) {
        [__es2Renderer release];
        __es2Renderer = nil;
    }
    if (__es1Renderer == nil) {
        __es1Renderer = [[Renderer alloc] init];
        __es1Renderer.internalRenderer = new GLES1DebugDraw();
        __es1Renderer.api = 1;
    }
    return __es1Renderer;
}

+ (Renderer*)ES2Renderer {
    if (__es1Renderer != nil) {
        [__es1Renderer release];
        __es1Renderer = nil;
    }
    if (__es2Renderer == nil) {
        __es2Renderer = [[Renderer alloc] init];
        __es2Renderer.internalRenderer = new GLES2DebugDraw();
        __es2Renderer.api = 2;
    }
    return __es2Renderer;
}

#pragma mark -
#pragma mark Setup

- (BOOL)loadTextures {
    numberOfTextures = 1;
    //    sheets = (spritesheet*)calloc(sizeof(spritesheet), 1);
    //    sheets[0] = [self loadTexture:@"text.png"];
    return YES;
}

std::string getFileAsString(std::string file, std::string type) {
    NSString* nsFile = [NSString stringWithFormat:@"%s",file.c_str()];
    NSString* nsType = [NSString stringWithFormat:@"%s",type.c_str()];
    NSString* path = [[NSBundle mainBundle] pathForResource:nsFile ofType:nsType];
    NSString* source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return std::string([source UTF8String]);
}

void bindMain(GLuint program) {
    glBindAttribLocation(program, ShaderProgramAttributePosition, "position");
    glBindAttribLocation(program, ShaderProgramAttributeColor, "color");
}

void bindText(GLuint program) {
    glBindAttribLocation(program, ShaderProgramAttributePosition, "position");
    glBindAttribLocation(program, ShaderProgramAttributeTexCoord, "texcoord");
}

- (BOOL)loadShaders {
    if (api == 1) {
        return NO;
    }
    
    // main shader
    ShaderProgram* program = ShaderProgram::namedInstance("main");
    if(!program->compileProgram("ShaderVaryingColor.vsh", "ShaderVaryingColor.fsh", &bindMain)) {
        return NO;
    }
    // text shader
    program = ShaderProgram::namedInstance("text");
    if (!program->compileProgram("TexShader.vsh", "TexShader.fsh", &bindText)) {
        return NO;
    }
    
    glUseProgram(ShaderProgram::namedInstance("main")->name());
    return YES;
}

- (void)setScreenWidth:(float)width andHeight:(float)height {
    internalRenderer->screenWidth = width;
    internalRenderer->screenHeight = height;
}

- (float)screenWidth {
    return internalRenderer->screenWidth;
}

- (float)screenHeight {
    return internalRenderer->screenHeight;
}

#pragma mark -
#pragma mark Access

- (Matrix*)preMultiplyMatrix {
    return &preMatrix;
}

- (Matrix*)postMultiplyMatrix {
    return &postMatrix;
}

- (void)setZoomScale:(CGFloat)zoom {
    zoomScale = MIN(MAX(ZOOM_MIN, zoom), ZOOM_MAX);
}

- (CGFloat)zoomScale {
    return zoomScale;
}

#pragma mark -
#pragma mark Rendering

- (void)render:(b2World*)world {
    // clamp zoomScale
    
    if (!GLisInitialized) {
        GLisInitialized = YES;
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    glClearColor(0.2, 0.2, 0.2, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    switch (api) {
        case 1: {
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity();
            break;
        }
        case 2: {
            float halfwidth = [self screenWidth]/2.0;
            float halfheight = [self screenHeight]/2.0;
            Matrix projection;
            projection.loadOrtho(-halfwidth, halfwidth, halfheight, -halfheight, -1.0, 1.0);
            Matrix cameraview;
            cameraview.multiply(preMatrix);
            cameraview.scale(zoomScale, zoomScale);
            cameraview.multiply(postMatrix);
            Matrix modelview;
            
            ShaderProgram* program = ShaderProgram::namedInstance("main");
            glUniformMatrix4fv(program->uniform("projection"), 1, GL_FALSE, &projection.elements[0]);
            glUniformMatrix4fv(program->uniform("cameraview"), 1, GL_FALSE, &cameraview.elements[0]);
            glUniformMatrix4fv(program->uniform("modelview"), 1, GL_FALSE, &modelview.elements[0]);
            glUniform1f(program->uniform("alpha"), 1.0);
            
            static bool done = false;
            if (!done) {
                done = true;
            }
            break;
        }
        default:
            break;
    }
    
    [self drawScene];
    //internalRenderer->DrawOrigin();
    // clear our multiply matrix
    preMatrix.loadIdentity();
    postMatrix.loadIdentity();
    
    [self drawUserInterface];
}

- (void)drawScene {
    DrawableUserData* userData;
    b2World* world = [[MachineMashModel sharedModel] world];
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        userData = (DrawableUserData*)b->GetUserData();
        if (userData == (DrawableUserData*)0) {
            const b2Transform& xf = b->GetTransform();
            for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()) {
                userData = (DrawableUserData*)f->GetUserData();
                if (userData == (DrawableUserData*)0) {
                    if (b->IsActive() == false) {
                        internalRenderer->DrawShape(f, xf, b2Color(1.0, 1.0, 0.0f));
                    } else if (b->GetType() == b2_staticBody) {
                        internalRenderer->DrawShape(f, xf, b2Color(0.0, 1.0, 1.0));
                    } else if (b->GetType() == b2_kinematicBody) {
                        internalRenderer->DrawShape(f, xf, b2Color(1.0, 0.0, 1.0));
                    } else if (b->IsAwake() == false) {
                        internalRenderer->DrawShape(f, xf, b2Color(0.6f, 0.6f, 0.6f));
                    } else {
                        internalRenderer->DrawShape(f, xf, b2Color(1.0, 1.0, 1.0));
                    }
                } else {
                    userData->draw(f);
                }
            }
        } else {
            userData->draw(b);
        }
    }
	for (b2Joint* j = world->GetJointList(); j; j = j->GetNext()) {
        userData = (DrawableUserData*)j->GetUserData();
        if (userData == (DrawableUserData*)0) {
            internalRenderer->DrawJoint(j);
        } else {
            userData->draw(j);
        }
    }
}

- (void)drawUserInterface {}

#pragma mark -
#pragma mark Texture

- (void)loadTexture:(NSString*)imageName {
//    [[GLProgram getProgramByIdentifier:@"tex"] use];
//    
//    CGImageRef textureImage = [UIImage imageNamed:imageName].CGImage;
//    spritesheet* tex = (spritesheet*)calloc(sizeof(spritesheet), 1);
//    
//    if (textureImage == nil) {
//        NSLog(@"Failed to load texture image %@",imageName);
//    } else {
//        tex->width = CGImageGetWidth(textureImage);
//        tex->height = CGImageGetHeight(textureImage);
//        
//        GLubyte *textureData = (GLubyte *)calloc(tex->width * tex->height, 4);
//        
//        CGContextRef textureContext = CGBitmapContextCreate(textureData, tex->width, tex->height, 8, tex->width * 4, CGImageGetColorSpace(textureImage), kCGImageAlphaPremultipliedLast);
//        CGContextSetBlendMode(textureContext, kCGBlendModeCopy);
//        CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)tex->width, (float)tex->height), textureImage);
//        
//        CGContextRelease(textureContext);
//        
//        glGenTextures(1, &tex->texture);
//        glBindTexture(GL_TEXTURE_2D, tex->texture);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex->width, tex->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
//        
//        free(textureData);
//        
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//        glEnable(GL_TEXTURE_2D);
//        glEnable(GL_BLEND);
//        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
//    }
//    spritesheet sheet;
//    memcpy(&sheet, tex, sizeof(spritesheet));
//    free(tex);
//    return sheet;
}

@end