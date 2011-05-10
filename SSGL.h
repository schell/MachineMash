//
//  SSGL.h
//  MachineMash
//
//  Created by Schell Scivally on 4/25/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#ifndef __SSGL__
#define __SSGL__

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <map>
#include <string>
#include "GLMath.h"

#define ASCII_START 0x21
#define ASCII_END 0x7E

#pragma mark -
#pragma mark Rectangles

typedef struct rectangle {
	float left;
	float top;
	float right;
	float bottom;
} rectangle;

rectangle rectangleMake(float left, float top, float right, float bottom);
rectangle rectangleWHMake(float left, float top, float width, float height);

#pragma mark -
#pragma mark Sprites

typedef struct spritesheet {
	unsigned int texture;				// the texture name
	unsigned int width;					// pixel width of texture
	unsigned int height;				// pixel height of texture
} spritesheet;

typedef struct spriteseq {
	spritesheet sheet;
	unsigned int framewidth;			// pixel width of one frame
	unsigned int frameheight;			// pixel height of one frame
	unsigned int offsetx;				// offset of first frame in x
	unsigned int offsety;				// offset of first frame in y
} spriteseq;

spritesheet spritesheetMake(unsigned int texture, unsigned int width, unsigned int height);
spriteseq spriteseqMake(spritesheet sheet, unsigned int framewidth, unsigned int frameheight, unsigned int x, unsigned int y);

#pragma mark -
#pragma mark Animations

typedef struct frame {
	frame* next;
	frame* prev;
	rectangle bounds;
} frame;

frame frameMake(rectangle bounds);
void frameJoin(frame* head, frame* tail);
void frameLinkFrames(frame frames[], int numFrames);
frame frameMakeAndAppendTo(rectangle bounds, frame* toAppendTo);
frame* frameAtIndexFrom(frame* head, int ndx, int wrap);
size_t frameCountLinkedFrames(frame* head);

typedef struct animation {
	spritesheet sheet;
	clock_t clockDelta;
	float clocksPerFrame;
	frame firstFrame;
	frame currentFrame;
    size_t ticks;
    size_t totalFrames;
} animation;

animation animationMake(spritesheet sheet, size_t framesPerSecond, frame firstFrame);
void animationTick(animation* anime, clock_t dt);

#pragma mark -
#pragma mark Geometry Mapping

typedef struct geomap {				 
	float* vertices;		
	float* uvs;
	unsigned int numfloats;
} geomap;

geomap geomapMakeBlank(size_t size);
geomap geomapMakeFromSeqWithFrame(spriteseq sequence, unsigned int frame);
geomap geomapMakeFromSeqWithChar(spriteseq sequence, char c);
geomap geomapMakeFromSeqWithString(spriteseq sequence, const char* string, float kerning);
geomap geomapMakeFromAnimation(animation sequence);
void geomapTranslate2D(geomap* map, float x, float y);
void geomapConcatenateIntoMap(geomap* into, geomap* from); 
void geomapDestroy(geomap* map);

#pragma mark -
#pragma mark Convenient Destruction For All!

void destroy(geomap* map);

#endif