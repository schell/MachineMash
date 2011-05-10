//
//  VertexBufferObject.h
//  MachineMash
//
//  Created by Schell Scivally on 5/3/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __VERTEXBUFFEROBJECT_CLASS__
#define __VERTEXBUFFEROBJECT_CLASS__

#include <string>
#include <vector>
#include <map>
#include <OpenGLES/ES2/gl.h>

class VertexBufferObject {
public:
    VertexBufferObject(std::string);
    ~VertexBufferObject();
    size_t stride();
    size_t vertexCount();
    void addAttributeData(std::vector<float>*, unsigned int, unsigned int);
    void store();
    GLuint getId();
    void print();
    virtual void draw();
    void unload();
    
    GLuint shaderProgramName;
    GLenum drawMode;
private:
    GLuint id;
    std::string name;
    std::vector<GLfloat> data;
    std::vector<size_t> attributeElementCounts;
    std::vector<unsigned int> attributeIndices;
    bool stored;
    bool unloaded;
    size_t numVertices;
    static std::map<std::string, GLuint> vboMap;
};

#endif