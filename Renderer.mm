//
//  Renderer.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#import "Renderer.h"
#import "GLProgram.h"
#import "GLMath.h"
#import "MachineMashModel.h"
#import <math.h>

#define ZOOM_MIN 2.0
#define ZOOM_MAX 60.0

#pragma -
#pragma RENDERER

@implementation Renderer
@synthesize internalRenderer, api, program;

#pragma -
#pragma Lifecycle

- (id)init {
    self = [super init];
    GLisInitialized = NO;
    zoomScale = ZOOM_MIN + (ZOOM_MAX - ZOOM_MIN)/2;
    mat4LoadIdentity(&preMatrix);
    mat4LoadIdentity(&postMatrix);
    return self;
}

- (void)dealloc {
    delete internalRenderer;
    [program release];
    [super dealloc];
}


#pragma -
#pragma Class Methods

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
        [__es1Renderer setFlags];
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
        [__es2Renderer setFlags];
        __es2Renderer.api = 2;
    }
    return __es2Renderer;
}

#pragma -
#pragma Setup

- (void)setFlags {
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    //		flags += b2DebugDraw::e_jointBit;
    //		flags += b2DebugDraw::e_aabbBit;
    //		flags += b2DebugDraw::e_pairBit;
    //		flags += b2DebugDraw::e_centerOfMassBit;
    self.internalRenderer->SetFlags(flags);
}

- (BOOL)loadShaders {
    if (api == 1) {
        return NO;
    }
   
    // main shader
    NSString* vShaderPathname;// = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString* fShaderPathname;// = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
	NSArray* pUniforms;// = [NSArray arrayWithObjects:@"projection",@"modelview",@"color",nil];
    GLProgram* tempProg;// = [[GLProgram alloc] initWithVertexShader:vShaderPathname 
//                                                andFragmentShader:fShaderPathname 
//                                                      andUniforms:pUniforms
//                                                     andBindBlock:^(GLuint name) {
//                                                         glBindAttribLocation(name, GLProgramAttributePosition, "position");
//                                                     }];
//    if (tempProg == nil) {
//        return NO;
//    }
//    [GLProgram storeProgram:tempProg withIdentifier:@"main"];
    
    // color varying shader
    vShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShaderVaryingColor" ofType:@"vsh"];
    fShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShaderVaryingColor" ofType:@"fsh"];
	pUniforms = [NSArray arrayWithObjects:@"projection",@"modelview",nil];
    tempProg = tempProg = [[GLProgram alloc] initWithVertexShader:vShaderPathname 
                                                andFragmentShader:fShaderPathname 
                                                      andUniforms:pUniforms
                                                     andBindBlock:^(GLuint name) {
                                                         glBindAttribLocation(name, GLProgramAttributePosition, "position");
                                                         glBindAttribLocation(name, GLProgramAttributeColor, "color");
                                                     }];
    if (tempProg == nil) {
        return NO;
    }
    [GLProgram storeProgram:tempProg withIdentifier:@"main"];
    
    // 
    program = [GLProgram getProgramByIdentifier:@"main"];
    ((GLES2DebugDraw*)internalRenderer)->program = [program name];
    return TRUE;
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

#pragma -
#pragma Access

- (mat4*)preMultiplyMatrix {
    return &preMatrix;
}

- (mat4*)postMultiplyMatrix {
    return &postMatrix;
}

- (void)setZoomScale:(CGFloat)zoom {
    zoomScale = MIN(MAX(ZOOM_MIN, zoom), ZOOM_MAX);
}

- (CGFloat)zoomScale {
    return zoomScale;
}

#pragma -
#pragma Rendering

- (void)render:(b2World*)world {
    // clamp zoomScale
    
    if (!GLisInitialized) {
        GLisInitialized = YES;
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
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
            glClearColor(0.0, 0.0, 0.0, 0.0);
            glClear(GL_COLOR_BUFFER_BIT);
            
            float halfwidth = [self screenWidth]/2.0;
            float halfheight = [self screenHeight]/2.0;
            
            mat4 projection;
            mat4LoadOrtho(&projection,-halfwidth, halfwidth, halfheight, -halfheight, -1.0, 1.0);
            mat4 modelview;
            mat4LoadIdentity(&modelview);
            mat4Multiply(&modelview, &preMatrix);
            mat4Scale(&modelview, zoomScale, zoomScale, 1.0);
            mat4Multiply(&modelview, &postMatrix);
            
            glUniformMatrix4fv([program uniformLocationFor:@"projection"], 1, GL_FALSE, &projection[0]);
            glUniformMatrix4fv([program uniformLocationFor:@"modelview"], 1, GL_FALSE, &modelview[0]);
            
            const GLfloat r = 370.0;
            
            vertexbuffer circle = verticesForCircleWithCountAddOrigin(b2Vec2(0.0, 0.0), r, 32, true);
            vertexbuffer colors = colorBufferForColor(b2Color(0.0, 0.0, 0.0), 0.0, circle.count);
            colors.vertices[0] = 0.0/255.0;
            colors.vertices[1] = 167.0/255.0;
            colors.vertices[2] = 255.0/255.0;
            colors.vertices[3] = 1.0;
            enableAttribArrays(circle, colors);
            glDrawArrays(GL_TRIANGLE_FAN, 0, circle.count);
            cleanUpBuffers(circle, colors);
            break;
        }
        default:
            break;
    }
    
    world->DrawDebugData();
    //internalRenderer->DrawOrigin();
    // clear our multiply matrix
    mat4LoadIdentity(&preMatrix);
    mat4LoadIdentity(&postMatrix);
}

@end