//
//  Sprite.h
//  MachineMash
//
//  Created by Schell Scivally on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include <string>
#include <vector>
#include <map>
#include "SSGL.h"
#include "GLMath.h"
#include "VertexBufferObject.h"

class Sprite {
public:
    Sprite();
    ~Sprite();
    virtual void draw();
    
    mat4 matrix;
    float alpha;
    //    std::vector<VertexBufferObject> vbos;
};