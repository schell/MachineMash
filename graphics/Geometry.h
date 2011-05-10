//
//  Geometry.h
//  MachineMash
//
//  Created by Schell Scivally on 5/5/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __GEOMETRY_CLASS__
#define __GEOMETRY_CLASS__

#include <vector>

class Geometry {
public:
    static std::vector<float> rectangle(float, float, float, float);
    static std::vector<float> circle(float,float,float,float);
    static std::vector<float> circle(float);
};

#endif