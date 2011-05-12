//
//  Matrix.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Matrix.h"
#include <cmath>

Matrix::Matrix():Vec(0) {
    this->loadIdentity();
}

Matrix::Matrix(float e1,float e2,float e3,float e4,float e5,float e6,float e7,float e8,float e9,float e10,float e11,float e12,float e13,float e14,float e15,float e16):Vec(16,e1,e2,e3,e4,e4,e6,e7,e8,e9,e10,e11,e12,e13,e14,e15,e16) {}

Matrix::~Matrix() {}

void Matrix::loadIdentity() {
    Matrix identity(1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    0.0, 0.0, 0.0, 1.0);
    this->elements = identity.elements;
}

// load a parallel projection matrix
void Matrix::loadOrtho(float left, float right, float top, float bottom, float far, float near) {
	float a,b,c,x,y,z;
	a = 2.0f/(right-left);
	b = 2.0f/(top-bottom);
	c = -2.0f/(far-near);
	x = -(right+left)/(right-left);
	y = -(top+bottom)/(top-bottom);
	z = -(far+near)/(far-near);
	Matrix ortho(  
		 a  ,0.0f,0.0f,  x ,
        0.0f,  b ,0.0f,  y ,
        0.0f,0.0f,  c ,  z ,
        0.0f,0.0f,0.0f,1.0f);
	this->elements = ortho.elements;
}

void Matrix::multiply(Matrix by) {
	Matrix product;
	for (int i = 0; i<4; i++) {
		product.elements.at(i*4+0) = (this->elements.at(i*4+0) * by.elements.at(0*4+0)) +
		(this->elements.at(i*4+1) * by.elements.at(1*4+0)) +
		(this->elements.at(i*4+2) * by.elements.at(2*4+0)) +
		(this->elements.at(i*4+3) * by.elements.at(3*4+0));
		                            
		product.elements.at(i*4+1) = (this->elements.at(i*4+0 ) * by.elements.at(0*4+1)) + 
		(this->elements.at(i*4+1) * by.elements.at(1*4+1)) +
		(this->elements.at(i*4+2) * by.elements.at(2*4+1)) +
		(this->elements.at(i*4+3) * by.elements.at(3*4+1));
		                            
		product.elements.at(i*4+2) = (this->elements.at(i*4+0 ) * by.elements.at(0*4+2)) + 
		(this->elements.at(i*4+1) * by.elements.at(1*4+2)) +
		(this->elements.at(i*4+2) * by.elements.at(2*4+2)) +
		(this->elements.at(i*4+3) * by.elements.at(3*4+2));
		                            
		product.elements.at(i*4+3) = (this->elements.at(i*4+0 ) * by.elements.at(0*4+3)) + 
		(this->elements.at(i*4+1) * by.elements.at(1*4+3)) +
		(this->elements.at(i*4+2) * by.elements.at(2*4+3)) +
		(this->elements.at(i*4+3) * by.elements.at(3*4+3));
	}
	this->elements = product.elements;
}

void Matrix::frustum(float left, float right, float bottom, float top, float nearZ, float farZ) {
	float       deltaX = right - left;
	float       deltaY = top - bottom;
	float       deltaZ = farZ - nearZ;
	if ( (nearZ <= 0.0f) || (farZ <= 0.0f) ||
		(deltaX <= 0.0f) || (deltaY <= 0.0f) || (deltaZ <= 0.0f) ) {
		return;
	}
	
	this->loadIdentity();
	
	this->elements.at(0*4+0) = 2.0f * nearZ / deltaX;
	this->elements.at(0*4+1) = this->elements.at(0*4+2) = this->elements.at(0*4+3) = 0.0f;
	
	this->elements.at(1*4+1) = 2.0f * nearZ / deltaY;
	this->elements.at(1*4+0) = this->elements.at(1*4+2) = this->elements.at(1*4+3) = 0.0f;
	
	this->elements.at(2*4+0) = (right + left) / deltaX;
	this->elements.at(2*4+1) = (top + bottom) / deltaY;
	this->elements.at(2*4+2) = -(nearZ + farZ) / deltaZ;
	this->elements.at(2*4+3) = -1.0f;
	
	this->elements.at(3*4+2) = -2.0f * nearZ * farZ / deltaZ;
	this->elements.at(3*4+0) = this->elements.at(3*4+1) = this->elements.at(3*4+3) = 0.0f;
}

void Matrix::perspective(float fovy, float aspect, float nearZ, float farZ) {
	float frustumW, frustumH;
	
	frustumH = tanf( fovy / 360.0f * TAO/2 ) * nearZ;
	frustumW = frustumH * aspect;
	this->frustum(-frustumW, frustumW, -frustumH, frustumH, nearZ, farZ);
}

void Matrix::scale(float sx, float sy, float sz) {
	this->elements.at(0*4+0) *= sx;
	this->elements.at(0*4+1) *= sx;
	this->elements.at(0*4+2) *= sx;
	this->elements.at(0*4+3) *= sx;
	
	this->elements.at(1*4+0) *= sy;
	this->elements.at(1*4+1) *= sy;
	this->elements.at(1*4+2) *= sy;
	this->elements.at(1*4+3) *= sy;
	
	this->elements.at(2*4+0) *= sz;
	this->elements.at(2*4+1) *= sz;
	this->elements.at(2*4+2) *= sz;
	this->elements.at(2*4+3) *= sz;
}

void Matrix::scale(float sx, float sy) {
    this->scale(sx, sy, 1.0);
}

void Matrix::translate(Vec3 along) {
    float tx,ty,tz;
    tx = along.x();
    ty = along.y();
    tz = along.z();
    this->elements.at(3*4+0) += (this->elements.at(0*4+0) * tx + this->elements.at(1*4+0) * ty + this->elements.at(2*4+0) * tz);
    this->elements.at(3*4+1) += (this->elements.at(0*4+1) * tx + this->elements.at(1*4+1) * ty + this->elements.at(2*4+1) * tz);
    this->elements.at(3*4+2) += (this->elements.at(0*4+2) * tx + this->elements.at(1*4+2) * ty + this->elements.at(2*4+2) * tz);
    this->elements.at(3*4+3) += (this->elements.at(0*4+3) * tx + this->elements.at(1*4+3) * ty + this->elements.at(2*4+3) * tz);
}

void Matrix::translate(Vec2 vec) {
    this->translate(Vec3(vec.x(), vec.y(), 0.0));
}

Vec3 Matrix::right() {
    Vec3 r(this->elements.at(0),this->elements.at(4),this->elements.at(8));
    return r;
}

Vec3 Matrix::up() {
    Vec3 u(this->elements.at(1),this->elements.at(5),this->elements.at(9));
    return u;
}

Vec3 Matrix::out() {
    Vec3 o(this->elements.at(2),this->elements.at(6),this->elements.at(10));
    return o;
}

void Matrix::moveForward(float amount) {
	Vec3 v = this->out();
	this->translate(Vec3(v.elements.at(0)*amount, v.elements.at(1)*amount, v.elements.at(2)*amount));
}

void Matrix::moveBackward(float amount) {
	this->moveForward(-amount);
}

void Matrix::moveDown(float amount) {
	Vec3 v = this->up();
	this->translate(Vec3(v.elements.at(0)*amount, v.elements.at(1)*amount, v.elements.at(2)*amount));
}

void Matrix::moveUp(float amount) {
	this->moveDown(-amount);
}

void Matrix::moveLeft(float amount) {
	Vec3 v = this->right();
	this->translate(Vec3(v.elements.at(0)*amount, v.elements.at(1)*amount, v.elements.at(2)*amount));
}

void Matrix::moveRight(float amount) {
	this->moveLeft(-amount);
}

void Matrix::rotate(float angle, Vec3 around) {
    float x,y,z;
    x = around.x();
    y = around.y();
    z = around.z();
	float sinAngle, cosAngle;
	float mag = sqrtf(x * x + y * y + z * z);
	
	sinAngle = sinf ( angle * ONE_DEGREE );
	cosAngle = cosf ( angle * ONE_DEGREE );
	if ( mag > 0.0f )
	{
		float xx, yy, zz, xy, yz, zx, xs, ys, zs;
		float oneMinusCos;
		
		x /= mag;
		y /= mag;
		z /= mag;
		
		xx = x * x;
		yy = y * y;
		zz = z * z;
		xy = x * y;
		yz = y * z;
		zx = z * x;
		xs = x * sinAngle;
		ys = y * sinAngle;
		zs = z * sinAngle;
		oneMinusCos = 1.0f - cosAngle;
		
        Matrix rotationMatrix;
		
		rotationMatrix.elements.at(0*4+0) = (oneMinusCos * xx) + cosAngle;
		rotationMatrix.elements.at(0*4+1) = (oneMinusCos * xy) + zs;
		rotationMatrix.elements.at(0*4+2) = (oneMinusCos * zx) - ys;
		rotationMatrix.elements.at(0*4+3) = 0.0F;
		
		rotationMatrix.elements.at(1*4+0) = (oneMinusCos * xy) - zs;
		rotationMatrix.elements.at(1*4+1) = (oneMinusCos * yy) + cosAngle;
		rotationMatrix.elements.at(1*4+2) = (oneMinusCos * yz) + xs;
		rotationMatrix.elements.at(1*4+3) = 0.0F;
		
		rotationMatrix.elements.at(2*4+0) = (oneMinusCos * zx) + ys;
		rotationMatrix.elements.at(2*4+1) = (oneMinusCos * yz) - xs;
		rotationMatrix.elements.at(2*4+2) = (oneMinusCos * zz) + cosAngle;
		rotationMatrix.elements.at(2*4+3) = 0.0F;
		
		rotationMatrix.elements.at(3*4+0) = 0.0F; 
		rotationMatrix.elements.at(3*4+1) = 0.0F;
		rotationMatrix.elements.at(3*4+2) = 0.0F; 
		rotationMatrix.elements.at(3*4+3) = 1.0F;
		
		this->multiply(rotationMatrix);
	}
}

void Matrix::spinRight(float amount) {
	if (!amount) {
		amount = ONE_DEGREE;
	}
	this->rotate(amount, Vec3(0.0, 1.0, 0.0));
}

void Matrix::spinLeft(float amount) {
	this->spinRight(-amount);
}

void Matrix::spinDown(float amount) {
	if (!amount) {
		amount = ONE_DEGREE;
	}
	this->rotate(amount, Vec3(1.0, 0.0, 0.0));
}

void Matrix::spinUp(float amount) {
	this->spinDown(-amount);
}

void Matrix::spinClockwise(float amount) {
	if (!amount) {
		amount = ONE_DEGREE;
	}
	this->rotate(amount, Vec3(0.0, 0.0, 1.0));
}

void Matrix::spinCounterClockwise(float amount) {
	this->spinClockwise(-amount);
}