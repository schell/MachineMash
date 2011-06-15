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
    static std::vector<float> rectangle(float cx, float cy, float w, float h);
    static std::vector<float> texRect(float cx, float cy, float w, float h);
    static std::vector<float> circle(float cx,float cy,float r,float n);
    static std::vector<float> circle(float r);
    static std::vector<float> grid(float w, float h, float xdivs, float ydivs);
    static std::vector<float> texGrid(float w, float h, float xdivs, float ydivs);
    
    static std::vector<unsigned short> triStripElements(unsigned int xdivs, unsigned int ydivs);
    template<class T>
    static std::vector<T> repeat(std::vector<T> data, unsigned int times) {
        std::vector<T> repeated;
        for (int i = 0; i<times; i++) {
            for (size_t n = 0; n < data.size(); n++) {
                repeated.push_back(data.at(n));
            }
        }
        return repeated;
    }
};

#endif