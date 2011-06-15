//
//  Buffer.h
//  MachineMash
//
//  Created by Schell Scivally on 5/14/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __BUFFER_CLASS__
#define __BUFFER_CLASS__

#include <vector>

/**
 *	A helper for vertex/index buffers.
 *  
 *	@author Schell Scivally
 */
template <class T>
class Buffer {
public:
    //--------------------------------------
    //  Functions
    //--------------------------------------
    /**
     *  Constructor
     */
    Buffer():_elementCount(0) {}
    /**
     *	Constructor.
     *  Adds data.
     *
     *	@param  std::vector<T> The initial data in this buffer.
     *	@param  unsigned int The number of elements in the initial buffer.
     */
    Buffer(std::vector<T> data, unsigned int elementCount):data(data),_elementCount(elementCount) {
        this->_offsets.push_back(0);
    }
    /**
     *  Deconstructor
     */
    ~Buffer() {
        this->data.clear();
    }
    /**
     *	Returns the stride (in bytes) of one vertex.
     *
     *	@return unsigned int The number of bytes one vertex occupies
     */
    unsigned int stride() {
        return sizeof(T) * this->_elementCount;
    }
    /**
     *	Returns the offset of the nth element.
     *
     *	@param  unsigned int The index of the element to return the offset of.
     *	@return unsigned int The offset in bytes of the nth element.
     */
    unsigned int offsetOf(unsigned int n) {
        return sizeof(T)*this->_offsets.at(n);
    }
    /**
     *	The number of vertices in this buffer.
     *
     *	@return  unsigned int The vertex count
     */
    unsigned int vertexCount() {
        return this->data.size()/this->_elementCount;
    }
    /**
     *	Interleaves data into this buffer.
     *
     *	@param  std::vector<T> The data to interleave.
     *  @param  unsigned int The number of elements in each vertex of this data.
     *	@return void 
     */
    void interleaveData(std::vector<T> buffer, unsigned int elementCount) {
        // interleave the data
        size_t vertexCount = this->vertexCount();
        std::vector<float> newData;
        if (vertexCount == 0) {
            newData.swap(buffer);
        }
        for (size_t v = 0; v < vertexCount; v++) {
            // push the existing attribute data
            for (size_t s = 0; s < this->_elementCount; s++) {
                newData.push_back(this->data.at(v*this->_elementCount+s));
            }
            // add the new attribute data
            for (size_t e = 0; e < elementCount; e++) {
                newData.push_back(buffer.at(v*elementCount+e));
            }
        }
        this->_offsets.push_back(this->_elementCount);
        this->_elementCount += elementCount;
        this->data.clear();
        this->data.swap(newData);
    }
    //--------------------------------------
    //  Variables
    //--------------------------------------
    std::vector<T> data;
protected:
    /** The number of elements in each vertex */
    unsigned int _elementCount;
    /** An array holding the offsets of each vertex element */
    std::vector<unsigned int> _offsets;
};

#endif