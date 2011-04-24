//
//  GLProgram.h
//  Mod-2
//
//  Created by Schell Scivally on 3/2/11.
//  Copyright 2011 Electrunique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef enum {
    GLProgramAttributePosition,
    GLProgramAttributeColor,
    GLProgramAttributeCount
} GLProgramAttribute;

@interface GLProgram : NSObject {
	NSMutableDictionary* _uniforms;
	GLuint _name;
}
+ (void)storeProgram:(GLProgram*)program withIdentifier:(NSString*)identifier;
+ (GLProgram*)getProgramByIdentifier:(NSString*)identifier;
+ (GLProgram*)currentProgram;
+ (BOOL)validateProgram:(GLuint)program;
- (id)initWithVertexShader:(NSString*)vsh andFragmentShader:(NSString*)fsh andUniforms:(NSArray*)uniformNames andBindBlock:(void(^)(GLuint))bindBlock;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (GLuint)name;
- (GLuint)uniformLocationFor:(NSString*)uniformName;
- (void)use;
@end
