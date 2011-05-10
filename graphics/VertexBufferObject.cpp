//
//  VertexBufferObject.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "VertexBufferObject.h"
#include "ErrorHandler.h"

std::map<std::string, unsigned int> VertexBufferObject::vboMap;

VertexBufferObject::VertexBufferObject(std::string name) {
    this->name = name;
    this->stored = false;
    this->unloaded = false;
    this->numVertices = 0;
    this->drawMode = GL_TRIANGLE_FAN;
}

VertexBufferObject::~VertexBufferObject() {
    this->data.clear();
    this->attributeElementCounts.clear();
    this->attributeIndices.clear();
}

size_t VertexBufferObject::stride() {
    unsigned int stride = 0;
    for (size_t i = 0; i < this->attributeElementCounts.size(); i++) {
        stride += this->attributeElementCounts.at(i);
    }
    return stride;
}

size_t VertexBufferObject::vertexCount() {
    if (this->unloaded) {
        return this->numVertices;
    } else if (this->data.size() == 0) {
        return 0;
    }
    return this->data.size()/this->stride();
}

void VertexBufferObject::addAttributeData(std::vector<float>* data, unsigned int elements, unsigned int attributeIndex) {
    if (this->data.size() != 0 && data->size()/elements != this->vertexCount()) {
        printf("VertexBufferObject::addAttributeData() vertex count of incoming data does not match existing data.\n");
        exit(1);
        return;
    }
    // interleave the data
    size_t stride = this->stride();
    size_t vertexCount = this->vertexCount();
    std::vector<float> newData;
    if (vertexCount == 0) {
        newData.swap(*data);
    }
    for (size_t v = 0; v < vertexCount; v++) {
        // push the existing attribute data
        for (size_t s = 0; s < stride; s++) {
            newData.push_back(this->data.at(v*stride+s));
        }
        // add the new attribute data
        for (size_t e = 0; e < elements; e++) {
            newData.push_back(data->at(v*elements+e));
        }
    }
    this->attributeElementCounts.push_back(elements);
    this->attributeIndices.push_back(attributeIndex);
    this->data.clear();
    this->data.swap(newData);
}

void VertexBufferObject::store() {
    if (VertexBufferObject::vboMap.find(this->name) == VertexBufferObject::vboMap.end()) {
        GLuint bufferSize = sizeof(float)*this->data.size();
        GLuint vboId;
        ErrorHandler::checkErr("clear");
        glGenBuffers(1, &vboId);
        ErrorHandler::checkErr("VertexBufferObject::store-glGenBuffers");
        glBindBuffer(GL_ARRAY_BUFFER, vboId);
        glBufferData(GL_ARRAY_BUFFER, bufferSize, &this->data[0], GL_STATIC_DRAW);
        ErrorHandler::checkErr("VertexBufferObject::store-glBufferData");
        this->id = vboId;
        this->stored = true;
        // unload
        this->numVertices = this->vertexCount();
        this->unloaded = true;
        this->data.clear();
    } else {
        printf("VertexBufferObject::store() vbo has already been stored\n");
    }
}

GLuint VertexBufferObject::getId() {
    if (!this->stored) {
        this->store();
    }
    return this->id;
}

void VertexBufferObject::print() {
    printf("VertexBufferObject::print()\n  ");
    size_t i = 0;
    while (i < this->data.size()) {
        for (size_t a = 0; a < this->attributeElementCounts.size(); a++) {
            for (size_t e = 0; e < this->attributeElementCounts.at(a); e++) {
                printf("% 4.3f, ",this->data.at(i++));
            }
            if (a < this->attributeElementCounts.size()-1) {
                printf(" | ");
            }
        }
        printf("\n  ");
    }
}

void VertexBufferObject::draw() {
    glUseProgram(this->shaderProgramName);
    glBindBuffer(GL_ARRAY_BUFFER, this->getId());
    size_t stride = this->stride();
    unsigned int offset = 0;
    for (size_t i = 0; i<this->attributeElementCounts.size(); i++) {
        unsigned int elementCount = this->attributeElementCounts.at(i);
        glEnableVertexAttribArray(this->attributeIndices.at(i));
        glVertexAttribPointer(this->attributeIndices.at(i), elementCount, GL_FLOAT, GL_FALSE, stride*sizeof(float), (const void*)offset);
        offset += elementCount*sizeof(float);
    }
    glDrawArrays(this->drawMode, 0, this->vertexCount());
    ErrorHandler::checkErr("VertexBufferObject::draw()");
}

void VertexBufferObject::unload() {
    if (this->stored) {
        glDeleteBuffers(1, &this->id);
    }
    this->stored = false;
    this->unloaded = false;
    this->numVertices = 0;
    this->drawMode = GL_TRIANGLE_FAN;
    this->data.clear();
    this->attributeElementCounts.clear();
    this->attributeIndices.clear();
}