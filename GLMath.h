//
//  GLMath.h
//  MachineMash
//
//  Created by Schell Scivally on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include <math.h>
#include <time.h>

#define TAO 6.28318531
#define ONE_DEGREE 0.0174532925

#pragma mark -
#pragma mark Vectors

typedef float vec4[4];		// 4 component vector
typedef vec4 rbga;
typedef float vec3[3];		// 3 component vector
typedef vec3 rbg;
typedef float vec2[2];		// 2 component vector

void vec3Print(vec3* vec);

#pragma mark -
#pragma mark Matrices

typedef float mat4[16];		// 4x4 matrix

void mat4LoadMatrix(mat4* into, mat4* from);
void mat4LoadIdentity(mat4* matrix);
void mat4LoadOrtho(mat4* matrix, float left, float right, float top, float bottom, float far, float near);
void mat4Multiply(mat4* matrixInto, mat4* matrixBy);	
void mat4Frustum(mat4* matrix, float left, float right, float bottom, float top, float nearZ, float farZ);	
void mat4Perspective(mat4* matrix, float fovy, float aspect, float nearZ, float farZ);	
void mat4Scale(mat4* matrix, float sx, float sy, float sz);
void mat4Translate(mat4* matrix, float tx, float ty, float tz);
void mat4MoveForward(mat4* matrix, float amount);
void mat4MoveBackward(mat4* matrix, float amount);
void mat4MoveDown(mat4* matrix, float amount);
void mat4MoveUp(mat4* matrix, float amount); 
void mat4MoveLeft(mat4* matrix, float amount);
void mat4MoveRight(mat4* matrix, float amount); 
void mat4Rotate(mat4* matrix, float angle, float x, float y, float z);	
void mat4SpinRight(mat4* matrix, float amount);
void mat4SpinLeft(mat4* matrix, float amount);
void mat4SpinDown(mat4* matrix, float amount);
void mat4SpinUp(mat4* matrix, float amount);
void mat4SpinClockwise(mat4* matrix, float amount);
void mat4SpinCounterClockwise(mat4* matrix, float amount);
void mat4Print(mat4* matrix);
void mat4Right(mat4* matrix, vec3* vec);
void mat4Up(mat4* matrix, vec3* vec);
void mat4Out(mat4* matrix, vec3* vec);
