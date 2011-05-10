//
//  Color.h
//  MachineMash
//
//  Created by Schell Scivally on 5/6/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __COLOR_CLASS__
#define __COLOR_CLASS__

#include <vector>

class Color {
public:
    Color(float r, float g, float b, float a);
    ~Color();
    static std::vector<float> colorBuffer(Color* color, size_t length);
    static std::vector<float> colorBuffer(std::vector<Color*>* colors, size_t length);
    float r,b,g,a;
};

#endif