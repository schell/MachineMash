//
//  Vec.h
//  MachineMash
//
//  Created by Schell Scivally on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __VEC_CLASS__
#define __VEC_CLASS__

#include <cstdarg>
#include <vector>

class Vec {
public:
    Vec(unsigned int numberOfElements, ...);
    ~Vec();
    void print();
    Vec add(Vec* vec);
    Vec subtract(Vec* vec);
    Vec multiply(Vec* vec);
    Vec divide(Vec* vec);
    Vec normalized();
    float magnitude();
    
    std::vector<float> elements;
};

class Vec2 : public Vec {
public:
    Vec2(float x, float y);
    float x();
    float y();
};

class Vec3 : public Vec {
public:
    Vec3(float x, float y, float z);
    float x();
    float y();
    float z();
};

#endif