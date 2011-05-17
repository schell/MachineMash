//
//  Geometry.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/5/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "Geometry.h"
#include <cmath>


std::vector<float> Geometry::rectangle(float cx, float cy, float width, float height) {
    float hw = width/2.0;
    float hh = height/2.0;
    std::vector<float> rectangle;
    rectangle.push_back(cx+hw); rectangle.push_back(cy+hh);
    rectangle.push_back(cx-hw); rectangle.push_back(cy+hh);
    rectangle.push_back(cx-hw); rectangle.push_back(cy-hh);
    rectangle.push_back(cx+hw); rectangle.push_back(cy-hh);
    return rectangle;
}

std::vector<float> Geometry::circle(float cx, float cy, float radius, float points) {
    std::vector<float> circle;
    float inc = M_PI/points*2;
    for (float i = 0.0; i <= points; i++) {
        float iinc = i*inc;
        float x = cx + cos(iinc) * radius;
        float y = cy + sin(iinc) * radius;
        circle.push_back(x); 
        circle.push_back(y);
    }
    return circle;
}

std::vector<float> Geometry::circle(float radius) {
    return Geometry::circle(0.0, 0.0, radius, 360.0);
}