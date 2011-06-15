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

std::vector<float> Geometry::texRect(float cx, float cy, float width, float height) {
#if __APPLE__
    return Geometry::rectangle(cx, 1.0-cy, width, -height);
#endif
    return Geometry::rectangle(cx, cy, width, height);
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

std::vector<float> Geometry::grid(float w, float h, float xdivs, float ydivs) {
    std::vector<float> points;
    float dx = w/xdivs;
    float dy = h/ydivs;
    for (float j = 0; j<=ydivs; j++) {
        for (float i = 0; i<=xdivs; i++) {
            float x = i*dx;
            float y = j*dy;
            points.push_back(x);
            points.push_back(y);
        }
    }
    return points;
}

std::vector<float> Geometry::texGrid(float w, float h, float xdivs, float ydivs) {
#if __APPLE__
    std::vector<float> points;
    float dx = w/xdivs;
    float dy = h/ydivs;
    for (float j = 0; j<=ydivs; j++) {
        for (float i = 0; i<=xdivs; i++) {
            float x = i*dx;
            float y = j*dy;
            points.push_back(x);
            points.push_back(h-y);
        }
    }
    return points;
#endif
    return Geometry::grid(w, h, xdivs, ydivs);
}

std::vector<unsigned short> Geometry::triStripElements(unsigned int xdivs, unsigned int ydivs) {
    std::vector<unsigned short> indices;
    for (int j = 0; j<=ydivs; j++) {
        unsigned short base = j * xdivs + j;
        for (int i = 0; i<=xdivs; i++) {
            indices.push_back(base+i);
            indices.push_back(base+i+xdivs+1);
        }
        // add a degenerate triangle
        indices.push_back(base+2*xdivs+1);
        indices.push_back(base+xdivs+1);
    }
    return indices;
}