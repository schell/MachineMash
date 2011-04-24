//
//  GLProgram.m
//  Mod-2
//
//  Created by Schell Scivally on 3/2/11.
//  Copyright 2011 Electrunique. All rights reserved.
//

#import "GLProgram.h"

@implementation GLProgram

#pragma mark -
#pragma mark Lifecycle

- (id)initWithVertexShader:(NSString*)vsh andFragmentShader:(NSString*)fsh 
               andUniforms:(NSArray*)uniformNames 
              andBindBlock:(void (^)(GLuint))bindBlock {
	self = [super init];
	
	GLuint vertShader, fragShader;
	
    // Create shader programs
    _name = glCreateProgram();
	
    // Create and compile vertex shader
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vsh]) {
        NSLog(@"%sFailed to compile vertex shader",__FUNCTION__);
        return FALSE;
    }
	
    // Create and compile fragment shader
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fsh]) {
        NSLog(@"%sFailed to compile fragment shader",__FUNCTION__);
        return FALSE;
    }
	
    // Attach vertex shader to program
    glAttachShader(_name, vertShader);
    // Attach fragment shaders to program
    glAttachShader(_name, fragShader);
	
    // Bind attribute locations
    // this needs to be done prior to linking
    bindBlock(_name);
	
    // Link program
    if (![self linkProgram:_name]) {
        NSLog(@"Failed to link program: %d", _name);
		
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_name)
        {
            glDeleteProgram(_name);
            _name = 0;
        }
        self = nil;
        return self;
    }
	
    // Get uniform locations and (somewhat) bind them
	for (NSString* uniformName in uniformNames) {
		NSNumber* location = [NSNumber numberWithInt:glGetUniformLocation(_name, [uniformName UTF8String])]; 
		if (_uniforms == nil) {
			_uniforms = [[NSMutableDictionary dictionary] retain];
		}
		[_uniforms setObject:location forKey:uniformName];
	}
	
    // Release vertex and fragment shaders
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
	
	return self;
}

- (void)dealloc {
    if (_name) {
        glDeleteProgram(_name);
        _name = 0;
    }
	if (_uniforms != nil) {
		[_uniforms removeAllObjects];
		[_uniforms release];
	}
	[super dealloc];
}

#pragma -
#pragma Class Methods

static NSMutableDictionary* __store = nil;
+ (void)storeProgram:(GLProgram*)program withIdentifier:(NSString*)identifier {
    if (__store == nil) {
        __store = [[NSMutableDictionary dictionary] retain];
    }
    [__store setObject:program forKey:identifier];
}

+ (GLProgram*)getProgramByIdentifier:(NSString*)identifier {
    return [__store objectForKey:identifier];
}

static GLProgram* current = nil;
+ (GLProgram*)currentProgram {
	return current;
}

+ (BOOL)validateProgram:(GLuint)prog {
    GLint logLength, status;
	
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
	
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
	
    return TRUE;
}

#pragma mark -
#pragma mark Access

- (GLuint)name {
	return _name;
}

- (GLuint)uniformLocationFor:(NSString*)uniformName {
	NSNumber* location = [_uniforms valueForKey:uniformName];
	if (location == nil) {
		return 0;
	}
	return [location intValue];
}

#pragma mark -
#pragma mark Setup

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
	
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load %@ shader",type == GL_FRAGMENT_SHADER ? @"fragment" : @"vertex");
        return FALSE;
    }
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
	
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
	
    glLinkProgram(prog);
	
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
	
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
	
    return TRUE;
}

#pragma mark -
#pragma mark Use

- (void)use {
	glUseProgram(_name);
	current = self;
}



@end
