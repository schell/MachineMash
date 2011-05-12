//
//  Matrix.h
//  MachineMash
//
//  Created by Schell Scivally on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __MATRIX_CLASS__
#define __MATRIX_CLASS__

#define TAO 6.28318531
#define ONE_DEGREE 0.0174532925

#include "Vec.h"

class Matrix : public Vec {
public:
    Matrix();
    Matrix(float e1,float e2,float e3,float e4,float e5,float e6,float e7,float e8,float e9,float e10,float e11,float e12,float e13,float e14,float e15,float e16);
    ~Matrix();
    void loadIdentity();
    void loadOrtho(float left, float right, float top, float bottom, float far, float near);
    void multiply(Matrix by);	
    void frustum(float left, float right, float bottom, float top, float nearZ, float farZ);	
    void perspective(float fovy, float aspect, float nearZ, float farZ);	
    void scale(float sx, float sy, float sz);
    void scale(float sx, float sy);
    void translate(Vec3 vec);
    void translate(Vec2 vec);
    void moveForward(float amount);
    void moveBackward(float amount);
    void moveDown(float amount);
    void moveUp(float amount); 
    void moveLeft(float amount);
    void moveRight(float amount); 
    void rotate(float angle, Vec3 vec);	
    void spinRight(float amount);
    void spinLeft(float amount);
    void spinDown(float amount);
    void spinUp(float amount);
    void spinClockwise(float amount);
    void spinCounterClockwise(float amount);
    void print();
    Vec3 right();
    Vec3 up();
    Vec3 out();
};

#endif