//
//  Color.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Color.h"

Color::Color(float r, float g, float b, float a):r(r),g(g),b(b),a(a) {}

Color::~Color() {}

std::vector<float> Color::colorBuffer(Color* color, size_t length) {
    std::vector<float> buffer;
    for (size_t i = 0; i<length; i++) {
        buffer.push_back(color->r);
        buffer.push_back(color->g);
        buffer.push_back(color->b);
        buffer.push_back(color->a);
    }
    return buffer;
}

std::vector<float> Color::colorBuffer(std::vector<Color*>* colors, size_t length) {
    std::vector<float> buffer;
    for (size_t i = 0; i<length; i++) {
        Color* color = colors->at(i%colors->size());
        buffer.push_back(color->r);
        buffer.push_back(color->g);
        buffer.push_back(color->b);
        buffer.push_back(color->a);
    }
    return buffer;
}