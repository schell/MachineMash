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
    /**
     * Constructor
     */
    VertexBufferObject();
    /**
     * Deconstructor
     */
    ~VertexBufferObject();
    /**
     *	Returns the stride between vertex elements.
     *
     *	@return size_t The number of elements in one vertex structure.
     */
    size_t stride();
    size_t vertexCount();
    void addAttributeData(std::vector<float>, unsigned int, unsigned int);
    void store();
    GLuint getId();
    void print();
    /**
     *	Switches to this VBO's shader program.
     *  Switches if necessary and returns true, if <code>glProgram</code> is
     *. the current shader program, returns false.
     *
     *	@return bool Whether or not the switch was made
     */
    bool switchToProgram();
    void prepareBuffers();
    void draw();
    void unload();
    
    GLuint glProgram;
    GLenum glDrawMode;
private:
    GLuint _id;
    std::vector<GLfloat> _data;
    std::vector<size_t> _attributeElementCounts;
    std::vector<unsigned int> _attributeIndices;
    bool _stored;
    size_t _numVertices;
    static GLuint __currentProgram;
};

#endif