//
//  ErrorHandler.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ErrorHandler.h"
#include <cstdio>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES2/gl.h>

void ErrorHandler::checkErr(std::string msg) {
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        printf("ErrorHandler::checkErr(%s)\n", msg.c_str());

        while (err != GL_NO_ERROR) {
            switch (err) {
                case GL_INVALID_ENUM:
                    printf("    (GL_INVALID_ENUM)");
                break;
                case GL_INVALID_VALUE:
                    printf("    (GL_INVALID_VALUE)");
                break;
                case GL_INVALID_OPERATION:
                    printf("    (GL_INVALID_OPERATION)");
                break;
                case GL_STACK_OVERFLOW:
                    printf("    (GL_STACK_OVERFLOW)");
                break;
                case GL_STACK_UNDERFLOW:
                    printf("    (GL_STACK_UNDERFLOW)");
                break;
                case GL_OUT_OF_MEMORY:
                    printf("    (GL_OUT_OF_MEMORY)");
                break;
            }
            printf(" found error %i\n", err);
            err = glGetError();
        }
    }
}
