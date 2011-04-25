//
//  SSGL.c
//  MachineMash
//
//  Created by Schell Scivally on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "SSGL.h"
#include <stdlib.h>
#include <string.h>

#pragma mark -
#pragma mark Rectangles

rectangle rectangleMake(float left, float top, float right, float bottom) {
	rectangle rect;
	rect.left = left;
	rect.top = top;
	rect.right = right;
	rect.bottom = bottom;
	return rect;
}

rectangle rectangleWHMake(float left, float top, float width, float height) {
	return rectangleMake(left, top, left+width, top+height);
}

#pragma mark -
#pragma mark Sprites

spritesheet spritesheetMake(unsigned int texture, unsigned int width, unsigned int height) {
	spritesheet sheet;
	sheet.texture = texture;
	sheet.width = width;
	sheet.height = height;
	return sheet;
}

spriteseq spriteseqMake(spritesheet sheet, unsigned int framewidth, unsigned int frameheight, unsigned int x, unsigned int y) {
	spriteseq seq;
	seq.sheet = sheet;
	seq.framewidth = framewidth;
	seq.frameheight = frameheight;
	seq.offsetx = x;
	seq.offsety = y;
	return seq;
}

#pragma mark -
#pragma mark Animation

frame frameMake(rectangle bounds) {
	frame f;
	f.next = 0;
	f.prev = 0;
	f.bounds = bounds;
	return f;
}

void frameJoin(frame* head, frame* tail) {
	if (head->next) {
		((frame*)head->next)->prev = 0;
	}
	head->next = tail;
	if (tail->prev) {
		((frame*)tail->prev)->next = 0;
	}
	tail->prev = head;
}

void frameLinkFrames(frame frames[], int numFrames) {
	while (--numFrames) {
		frameJoin(&frames[numFrames-1], &frames[numFrames]);
	}
}

frame frameMakeAndAppendTo(rectangle bounds, frame* toAppendTo) {
	frame f = frameMake(bounds);
	frameJoin(toAppendTo, &f);
	return f;
}

frame* frameAtIndexFrom(frame *head, int ndx, int wrap) {
	frame* it = head;
	int i = 0;
	while (it != (frame*)0 && i != ndx) {
		frame* last = it;
		it = it->next;
		if (it == (frame*)0) {
			it = wrap ? head : last;
		}
		i++;
	}
	return it;
}

size_t frameCountLinkedFrames(frame* head) {
    if (head->next == (void*)0) {
        return 1;
    }
    frame* it = head->next;
    int i = 1;
    // until we hit the end of the list or come back around
    while (it != (void*)0 && it != head) {
        it = it->next;
        i++;
    }
    return i;
}

animation animationMake(spritesheet sheet, size_t framesPerSecond, frame firstFrame) {
	animation ani;
	ani.sheet = sheet;
	ani.clockDelta = 0;
	ani.clocksPerFrame = CLOCKS_PER_SEC / framesPerSecond;
	ani.firstFrame = firstFrame;
	ani.currentFrame = firstFrame;
    ani.ticks = 0;
    ani.totalFrames = frameCountLinkedFrames(&firstFrame);
	return ani;
}

void animationTick(animation* anime, clock_t dt) {
	anime->clockDelta += dt;
	if (anime->clockDelta >= anime->clocksPerFrame) {
		anime->clockDelta -= anime->clocksPerFrame;
		anime->ticks++;
        if (anime->ticks >= anime->totalFrames) {
            anime->currentFrame = anime->firstFrame;
            anime->ticks = 0;
        } else {
            anime->currentFrame = *(frame*)anime->currentFrame.next;
        }
	}
}

#pragma mark -
#pragma mark Geometry Mapping

geomap_ geomapMakeBlank(size_t size) {
	geomap_ map;
	map.numfloats = size;
	map.vertices = (float*)malloc(size*sizeof(float));
	map.uvs = (float*)malloc(size*sizeof(float));
	memset(map.vertices, 0, size*sizeof(float));
	memset(map.uvs, 0, size*sizeof(float));
	return map;
}

geomap_ geomapMakeFromSeqWithFrame(spriteseq sequence, unsigned int frame) {
	// the extants of one frame
	float hw = ((float)sequence.framewidth)/2.0;
	float hh = ((float)sequence.frameheight)/2.0;
	// the number of frames along the x axis
	unsigned int xframes = sequence.sheet.width/sequence.framewidth;
	xframes = 1 > xframes ? 1 : xframes;
	// the normalized extants of one frame
	float pw = ((float)sequence.framewidth)/(float)sequence.sheet.width;
	float ph = ((float)sequence.frameheight)/(float)sequence.sheet.height;
	// the frame offsets of this frame
	unsigned int x = frame % xframes;
	unsigned int y = frame / xframes;
	// upper left tex coords
	float ulx = pw*(float)(x+sequence.offsetx);
	float uly = ph*(float)(y+sequence.offsety);
	
	size_t size = 8 * sizeof(float);
	geomap_ map;
	map.numfloats = 8;
	map.vertices = (float*)malloc(size);
	map.uvs = (float*)malloc(size);
	// 0    1
	// 		  the sequence of points
	// 2    3
	float vertices[] = {
		-hw,  hh,
        hw,  hh,
		-hw, -hh,
        hw, -hh
	};
	
	float uvs[] = {
		ulx,    uly,
		ulx+pw, uly,
		ulx,	uly+ph,
		ulx+pw, uly+ph
	};
	memcpy(map.vertices, vertices, size);
	memcpy(map.uvs, uvs, size);
	return map;
}

geomap_ geomapMakeFromSeqWithChar(spriteseq sequence, char c) {
	if (c < ASCII_START || c > ASCII_END) {
		return geomapMakeBlank(0);
	}
	unsigned int frame = c - ASCII_START;
	geomap_ map = geomapMakeFromSeqWithFrame(sequence, frame);
	return map;
}

geomap_ geomapMakeFromSeqWithString(spriteseq sequence, const char* string, float kerning) {
	char c = ' ';
	int i = 0;
	float x = 0;
	float y = 0;
	geomap_ map = geomapMakeBlank(0);
	while ((c = string[i++]) != '\0') {
		x += sequence.framewidth - kerning;
		if (c == '\t' || c == ' ') {
			continue;
		}
		if (c == '\n') {
			x = 0;
			y -= sequence.frameheight;
			continue;
		}
		geomap_ charmap = geomapMakeFromSeqWithChar(sequence, c);
		geomapTranslate2D(&charmap, x, y);
		geomapConcatenateIntoMap(&map, &charmap);
		destroy(&charmap);
	} 
	return map;
}

geomap_ geomapMakeFromAnimation(animation anime) {
	frame* frameAtNdx = &anime.currentFrame;
	rectangle bounds = frameAtNdx->bounds;
	float l = bounds.left;
	float t = bounds.top;
	float r = bounds.right;
	float b = bounds.bottom;
	
	float w = anime.sheet.width;
	float h = anime.sheet.height;
	float fw = r-l;
	float fh = b-t;
	float hw = fw/2.0;
	float hh = fh/2.0;
	float low = l/w;
	float toh = t/h;
	float row = r/w;
	float boh = b/h;
	
	size_t size = 8 * sizeof(float);
	geomap_ map;
	map.numfloats = 8;
	map.vertices = (float*)malloc(size);
	map.uvs = (float*)malloc(size);
	// 0    1
	// 		  the sequence of points
	// 2    3
	float vertices[] = {
		-hw,  hh,
		hw,  hh,
		-hw, -hh,
		hw, -hh
	};
	
	float uvs[] = {
		low, toh,
		row, toh,
		low, boh,
		row, boh
	};
	memcpy(map.vertices, vertices, size);
	memcpy(map.uvs, uvs, size);
	return map;
	
}

void geomapTranslate2D(geomap_* map, float x, float y) {
	for (int i = 0; i<map->numfloats; i+=2) {
		map->vertices[i] = map->vertices[i] + x;
		map->vertices[i+1] = map->vertices[i+1] + y;
	}
}

void geomapConcatenateIntoMap(geomap_* into, geomap_* from) {
	int prevfloats = into->numfloats;
	int totalfloats = into->numfloats + from->numfloats + 4;
	into->vertices = (float*)realloc(into->vertices, totalfloats*sizeof(float));
	into->vertices[prevfloats] = into->vertices[prevfloats-2];
	into->vertices[prevfloats+1] = into->vertices[prevfloats-1];
	into->vertices[prevfloats+2] = from->vertices[0];
	into->vertices[prevfloats+3] = from->vertices[1];
	memcpy(into->vertices+prevfloats+4, from->vertices, from->numfloats*sizeof(float));
	
	into->uvs = (float*)realloc(into->uvs, totalfloats*sizeof(float));
	into->uvs[prevfloats] = into->uvs[prevfloats-2];
	into->uvs[prevfloats+1] = into->uvs[prevfloats-1];
	into->uvs[prevfloats+2] = from->uvs[0];
	into->uvs[prevfloats+3] = from->uvs[1];
	memcpy(into->uvs+prevfloats+4, from->uvs, from->numfloats*sizeof(float));
	
	into->numfloats = totalfloats;
}

void geomapDestroy(geomap_* map) {
	free(map->vertices);
	free(map->uvs);
	map->numfloats = 0;
}

#pragma mark -
#pragma mark Convenient Destruction

void destroy(geomap_* map) {
	geomapDestroy(map);
}
