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
#include "VertexBufferObject.h"
#include "Geometry.h"
#include "Color.h"
#include "ErrorHandler.h"

#define ZOOM_MIN 2.0
#define ZOOM_MAX 60.0

@interface Renderer (PrivateMethods)
- (void)drawDebugData;
@end

#pragma mark -
#pragma mark RENDERER

@implementation Renderer
@synthesize internalRenderer, api, program;

VertexBufferObject rainbowSquare("rainbowSquare");

#pragma mark -
#pragma mark Lifecycle

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
    sheets = (spritesheet*)calloc(sizeof(spritesheet), 1);
    sheets[0] = [self loadTexture:@"text.png"];
    return YES;
}

- (BOOL)loadShaders {
    if (api == 1) {
        return NO;
    }
   
    // main shader
    NSString* vShaderPathname;
    NSString* fShaderPathname;
	NSArray* pUniforms;
    GLProgram* tempProg;

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
    
    // texture shader
    vShaderPathname = [[NSBundle mainBundle] pathForResource:@"TexShader" ofType:@"vsh"];
    fShaderPathname = [[NSBundle mainBundle] pathForResource:@"TexShader" ofType:@"fsh"];
	pUniforms = [NSArray arrayWithObjects:@"projection",@"modelview",@"sampler",@"color",@"colored",nil];
    tempProg = tempProg = [[GLProgram alloc] initWithVertexShader:vShaderPathname 
                                                andFragmentShader:fShaderPathname 
                                                      andUniforms:pUniforms
                                                     andBindBlock:^(GLuint name) {
                                                         glBindAttribLocation(name, GLProgramAttributePosition, "position");
                                                         glBindAttribLocation(name, GLProgramAttributeTexCoord, "texcoord");
                                                     }];
    if (tempProg == nil) {
        return NO;
    }
    [GLProgram storeProgram:tempProg withIdentifier:@"tex"];
    
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

#pragma mark -
#pragma mark Access

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
            
            mat4 projection;
            mat4LoadOrtho(&projection,-halfwidth, halfwidth, halfheight, -halfheight, -1.0, 1.0);
            mat4 modelview;
            mat4LoadIdentity(&modelview);
            mat4Multiply(&modelview, &preMatrix);
            mat4Scale(&modelview, zoomScale, zoomScale, 1.0);
            mat4Multiply(&modelview, &postMatrix);
            
            GLProgram* cvProg = [GLProgram getProgramByIdentifier:@"main"];
            [cvProg use];
            glUniformMatrix4fv([cvProg uniformLocationFor:@"projection"], 1, GL_FALSE, &projection[0]);
            glUniformMatrix4fv([cvProg uniformLocationFor:@"modelview"], 1, GL_FALSE, &modelview[0]);
            
            
            break;
        }
        default:
            break;
    }
    
    [self drawDebugData];
    //internalRenderer->DrawOrigin();
    // clear our multiply matrix
    mat4LoadIdentity(&preMatrix);
    mat4LoadIdentity(&postMatrix);
    
    [self drawUserInterface];
}

- (void)drawDebugData {
    b2World* world = [[MachineMashModel sharedModel] world];
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        const b2Transform& xf = b->GetTransform();
        for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()) {
            if (b->IsActive() == false)
            {
                internalRenderer->DrawShape(f, xf, b2Color(1.0, 1.0, 0.0f));
            }
            else if (b->GetType() == b2_staticBody)
            {
                internalRenderer->DrawShape(f, xf, b2Color(0.0, 1.0, 1.0));
            }
            else if (b->GetType() == b2_kinematicBody)
            {
                internalRenderer->DrawShape(f, xf, b2Color(1.0, 0.0, 1.0));
            }
            else if (b->IsAwake() == false)
            {
                internalRenderer->DrawShape(f, xf, b2Color(0.6f, 0.6f, 0.6f));
            }
            else
            {
                internalRenderer->DrawShape(f, xf, b2Color(1.0, 1.0, 1.0));
            }
        }
    }
    
	for (b2Joint* j = world->GetJointList(); j; j = j->GetNext()) {
        internalRenderer->DrawJoint(j);
    }
}

- (void)drawTexturedGeomap:(geomap *)geom {
	glUniform1f([[GLProgram getProgramByIdentifier:@"tex"] uniformLocationFor:@"sampler"], 0);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // Update attribute values
    glVertexAttribPointer(GLProgramAttributePosition, 2, GL_FLOAT, 0, 0, &geom->vertices[0]);
    glEnableVertexAttribArray(GLProgramAttributePosition);
    glVertexAttribPointer(GLProgramAttributeTexCoord, 2, GL_FLOAT, 1, 0, &geom->uvs[0]);
    glEnableVertexAttribArray(GLProgramAttributeTexCoord);
    // Draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, geom->numfloats/2.0);
}

- (void)drawUserInterface {
}

#pragma mark -
#pragma mark Texture

- (spritesheet)loadTexture:(NSString*)imageName {
    [[GLProgram getProgramByIdentifier:@"tex"] use];
    
    CGImageRef textureImage = [UIImage imageNamed:imageName].CGImage;
    spritesheet* tex = (spritesheet*)calloc(sizeof(spritesheet), 1);
    
    if (textureImage == nil) {
        NSLog(@"Failed to load texture image %@",imageName);
    } else {
        tex->width = CGImageGetWidth(textureImage);
        tex->height = CGImageGetHeight(textureImage);
        
        GLubyte *textureData = (GLubyte *)calloc(tex->width * tex->height, 4);
        
        CGContextRef textureContext = CGBitmapContextCreate(textureData, tex->width, tex->height, 8, tex->width * 4, CGImageGetColorSpace(textureImage), kCGImageAlphaPremultipliedLast);
        CGContextSetBlendMode(textureContext, kCGBlendModeCopy);
        CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)tex->width, (float)tex->height), textureImage);
        
        CGContextRelease(textureContext);
        
        glGenTextures(1, &tex->texture);
        glBindTexture(GL_TEXTURE_2D, tex->texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex->width, tex->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
        
        free(textureData);
        
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
    spritesheet sheet;
    memcpy(&sheet, tex, sizeof(spritesheet));
    free(tex);
    return sheet;
}

@end