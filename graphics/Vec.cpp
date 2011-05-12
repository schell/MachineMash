//
//  Vec.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Vec.h"
#include <cmath>

#pragma mark -
#pragma mark Helpers

Vec* vecWithMinElements(Vec* vec1, Vec* vec2) {
    return vec1->elements.size() < vec2->elements.size() ? vec1 : vec2;
}

#pragma mark -
#pragma mark Vec

Vec::Vec(unsigned int numberOfElements,...) {
    if (numberOfElements > 0) {
        va_list v1;
        va_start(v1, numberOfElements);
        for (int i = 0; i < numberOfElements; i++) {
            this->elements.push_back(va_arg(v1, double));
        }
        va_end(v1);
    }
}

Vec::~Vec() {
    this->elements.clear();
}

void Vec::print() {
    size_t count = this->elements.size();
    printf("Vec::print() %lu elements:",count);
    for (size_t i = 0; i<count; i++) {
        printf(" %f",this->elements.at(i));
    }
    printf("\n");
}

#pragma --math--

Vec Vec::add(Vec* vec) {
    Vec sum = *vecWithMinElements(this, vec);
    for (size_t i = 0; i<sum.elements.size(); i++) {
        sum.elements.at(i) += this->elements.at(i);
    }
    return sum;
}

Vec Vec::subtract(Vec* vec) {
    Vec diff = *vecWithMinElements(this, vec);
    for (size_t i = 0; i<diff.elements.size(); i++) {
        diff.elements.at(i) = this->elements.at(i) - diff.elements.at(i);
    }
    return diff;
}

Vec Vec::multiply(Vec* vec) {
    Vec product = *vecWithMinElements(this, vec);
    for (size_t i = 0; i<product.elements.size(); i++) {
        product.elements.at(i) *= this->elements.at(i);
    }
    return product;
}

Vec Vec::divide(Vec* vec) {
    Vec quotient = *vecWithMinElements(this, vec);
    for (size_t i = 0; i<quotient.elements.size(); i++) {
        quotient.elements.at(i) = this->elements.at(i)/quotient.elements.at(i);
    }
    return quotient;
}

Vec Vec::normalized() {
    Vec norm = *this; 
    float mag = this->magnitude();
    for (size_t i = 0; i<this->elements.size(); i++) {
        norm.elements.at(i) = this->elements.at(i)/mag;
    }
    return norm;
}

float Vec::magnitude() {
    float sqSum = 0;
    for (size_t i = 0; i<this->elements.size(); i++) {
        sqSum += this->elements.at(i)*this->elements.at(i);
    }
    return sqrtf(sqSum);
}

#pragma mark -
#pragma mark Vec2

Vec2::Vec2(float x, float y):Vec(2,x,y) {}

float Vec2::x() {
    return this->elements.at(0);
}

float Vec2::y() {
    return this->elements.at(1);
}

#pragma mark -
#pragma mark Vec3

Vec3::Vec3(float x, float y, float z):Vec(3,x,y,z) {}

float Vec3::x() {
    return this->elements.at(0);
}

float Vec3::y() {
    return this->elements.at(1);
}

float Vec3::z() {
    return this->elements.at(2);
}