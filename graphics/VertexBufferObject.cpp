//
//  VertexBufferObject.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/3/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "VertexBufferObject.h"
#include "ErrorHandler.h"

unsigned int VertexBufferObject::__currentProgram = 0;

VertexBufferObject::VertexBufferObject() {
    this->_id = 0;
    this->_stored = false;
    this->_numVertices = 0;
    this->glDrawMode = GL_TRIANGLE_FAN;
}

VertexBufferObject::~VertexBufferObject() {
    this->_data.clear();
    this->_attributeElementCounts.clear();
    this->_attributeIndices.clear();
}

size_t VertexBufferObject::stride() {
    unsigned int stride = 0;
    for (size_t i = 0; i < this->_attributeElementCounts.size(); i++) {
        stride += this->_attributeElementCounts.at(i);
    }
    return stride;
}

size_t VertexBufferObject::vertexCount() {
    if(this->_numVertices) {
        return this->_numVertices;
    } else if (this->_data.size() == 0) {
        return 0;
    }
    return this->_data.size()/this->stride();
}

void VertexBufferObject::addAttributeData(std::vector<float> data, unsigned int elements, unsigned int attributeIndex) {
    if (this->_data.size() != 0 && data.size()/elements != this->vertexCount()) {
        printf("VertexBufferObject::addAttributeData() vertex count of incoming data does not match existing data.\n");
        exit(1);
        return;
    }
    // interleave the data
    size_t stride = this->stride();
    size_t vertexCount = this->vertexCount();
    std::vector<float> newData;
    if (vertexCount == 0) {
        newData.swap(data);
    }
    for (size_t v = 0; v < vertexCount; v++) {
        // push the existing attribute data
        for (size_t s = 0; s < stride; s++) {
            newData.push_back(this->_data.at(v*stride+s));
        }
        // add the new attribute data
        for (size_t e = 0; e < elements; e++) {
            newData.push_back(data.at(v*elements+e));
        }
    }
    this->_attributeElementCounts.push_back(elements);
    this->_attributeIndices.push_back(attributeIndex);
    this->_data.clear();
    this->_data.swap(newData);
}

void VertexBufferObject::store() {
    if (!this->_stored) {
        GLuint bufferSize = sizeof(float)*this->_data.size();
        GLuint vboId;
        glGenBuffers(1, &vboId);
        glBindBuffer(GL_ARRAY_BUFFER, vboId);
        glBufferData(GL_ARRAY_BUFFER, bufferSize, &this->_data[0], GL_STATIC_DRAW);
        this->_id = vboId;
        if (this->_id == 0) {
            ErrorHandler::checkErr("VertexBufferObject::store() id was 0");
            return;
        }
        this->_stored = true;
        // unload from client space
        this->_numVertices = this->vertexCount();
        this->_data.clear();
    } else {
        printf("VertexBufferObject::store() vbo has already been stored\n");
    }
}

GLuint VertexBufferObject::getId() {
    if (!this->_stored) {
        this->store();
    }
    return this->_id;
}

void VertexBufferObject::print() {
    printf("VertexBufferObject::print()\n  ");
    size_t i = 0;
    while (i < this->_data.size()) {
        for (size_t a = 0; a < this->_attributeElementCounts.size(); a++) {
            for (size_t e = 0; e < this->_attributeElementCounts.at(a); e++) {
                printf("% 4.3f, ",this->_data.at(i++));
            }
            if (a < this->_attributeElementCounts.size()-1) {
                printf(" | ");
            }
        }
        printf("\n  ");
    }
}

bool VertexBufferObject::switchToProgram() {
    if (this->glProgram != VertexBufferObject::__currentProgram) {
        __currentProgram = this->glProgram;
        glUseProgram(this->glProgram);
        return true;
    }
    return false;
}

void VertexBufferObject::prepareBuffers() {
    this->switchToProgram();
    glBindBuffer(GL_ARRAY_BUFFER, this->getId());
    size_t stride = this->stride();
    unsigned int offset = 0;
    for (size_t i = 0; i<this->_attributeElementCounts.size(); i++) {
        unsigned int elementCount = this->_attributeElementCounts.at(i);
        glEnableVertexAttribArray(this->_attributeIndices.at(i));
        glVertexAttribPointer(this->_attributeIndices.at(i), elementCount, GL_FLOAT, GL_FALSE, stride*sizeof(float), (const void*)offset);
        offset += elementCount*sizeof(float);
    }
}

void VertexBufferObject::draw() {
    this->prepareBuffers();
    glDrawArrays(this->glDrawMode, 0, this->vertexCount());
}

void VertexBufferObject::unload() {
    if (this->_stored) {
        glDeleteBuffers(1, &this->_id);
    }
    this->_stored = false;
    this->_numVertices = 0;
    this->glDrawMode = GL_TRIANGLE_FAN;
    this->_data.clear();
    this->_attributeElementCounts.clear();
    this->_attributeIndices.clear();
}