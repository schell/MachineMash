//
//  GLESDebugDraw.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "GLESDebugDraw.h"
#import "Renderer.h"

#define PTM_RATIO 32.0f

#pragma -
#pragma Helpers

vertexbuffer verticesForCircleWithCountAddOrigin(const b2Vec2 &center, float32 radius, int32 count, bool fan) {
    const float32 k_segments = count;
	int vertexCount = k_segments+1;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
	GLfloat	glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x;
		glVertices[i*2+1]=v.y;
		theta += k_increment;
	}
    glVertices[vertexCount*2-2] = glVertices[0];
    glVertices[vertexCount*2-1] = glVertices[1];
    
    vertexbuffer buffer;
    if (fan) {
        size_t totalSize = sizeof(GLfloat)*(vertexCount + 1)*2;
        size_t circleSize = sizeof(GLfloat)*vertexCount*2;
        buffer.vertices = (GLfloat*)malloc(totalSize);
        buffer.vertices[0] = center.x;
        buffer.vertices[1] = center.y;
        memcpy((buffer.vertices+2), glVertices, circleSize);
        buffer.count = vertexCount+1;
    } else {
        size_t size = sizeof(GLfloat)*vertexCount*2;
        buffer.vertices = (GLfloat*)malloc(size);
        memcpy(buffer.vertices, glVertices, size);
        buffer.count = vertexCount;
    }
    
    return buffer;

}

vertexbuffer verticesForCircleWithCount(const b2Vec2 &center, float32 radius, int32 count) {
	return verticesForCircleWithCountAddOrigin(center, radius, count, false);
}

vertexbuffer verticesForCircle(const b2Vec2 &center, float32 radius) {
    CGFloat zoomScale = [[Renderer sharedRenderer] zoomScale];
    return verticesForCircleWithCount(center, radius, 4 + zoomScale * radius);
}

vertexbuffer colorBufferForColor(const b2Color &color, float32 alpha, int32 count) {
    vertexbuffer buffer;
    buffer.count = count;
    buffer.vertices = (GLfloat*)malloc(sizeof(GLfloat)*count*4);
    for (int i = 0; i < count; i++) {
        buffer.vertices[i*4] = color.r;
        buffer.vertices[i*4+1] = color.g;
        buffer.vertices[i*4+2] = color.b;
        buffer.vertices[i*4+3] = alpha;
    }
    return buffer;
}

void vertexbufferChangeAlpha(vertexbuffer buffer, float32 alpha) {
    for (int i = 0; i<buffer.count; i++) {
        buffer.vertices[i*4+3] = alpha;
    }
}

void enableAttribArrays(vertexbuffer buffer, vertexbuffer colors) {
    glVertexAttribPointer(GLProgramAttributePosition, 2, GL_FLOAT, 0, 0, buffer.vertices);
	glEnableVertexAttribArray(GLProgramAttributePosition);
    glVertexAttribPointer(GLProgramAttributeColor, 4, GL_FLOAT, 0, 0, colors.vertices);
	glEnableVertexAttribArray(GLProgramAttributeColor);
}

void cleanUpBuffers(vertexbuffer buffer, vertexbuffer colors) {
    free(buffer.vertices);
    free(colors.vertices);
}

#pragma -
#pragma GLESDEBUGDRAW

void GLESDebugDraw::DrawOrigin() {
    // draws axiis from -5 to +5 meters, radii are 1 meter
    const b2Vec2 origin = b2Vec2(0.0f, 0.0f);
    const b2Vec2 topcenter = b2Vec2(0.0f, -5.0f);
    const b2Vec2 bottomcenter = b2Vec2(0.0f, 5.0f);
    const b2Vec2 leftcenter = b2Vec2(-5.0f, 0.0f);
    const b2Vec2 rightcenter = b2Vec2(5.0f, 0.0f);
    const b2Color white = b2Color(255.0, 255.0, 255.0);
    // draw axiis
    this->DrawSegment(topcenter, bottomcenter, white);
    this->DrawSegment(leftcenter, rightcenter, white);
    // draw origin and axis endpoints
    this->DrawCircle(origin, 1.0, white);
    this->DrawSolidCircle(topcenter, 1, b2Vec2(1.0f, 0), white);
    this->DrawSolidCircle(rightcenter, 1, b2Vec2(0.0, 1.0f), white);
}

#pragma -
#pragma GLES2DEBUGDRAW

void GLES2DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glColor4f(color.r, color.g, color.b,1);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void GLES2DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color) {
    glUseProgram(this->program);
    
    vertexbuffer colors = colorBufferForColor(color, 0.5, vertexCount);
    
    glVertexAttribPointer(GLProgramAttributePosition, 2, GL_FLOAT, 0, 0, vertices);
	glEnableVertexAttribArray(GLProgramAttributePosition);
    glVertexAttribPointer(GLProgramAttributeColor, 4, GL_FLOAT, 0, 0, colors.vertices);
	glEnableVertexAttribArray(GLProgramAttributeColor);
    
//    GLuint cLoc = glGetUniformLocation(this->program, "color");
//    glUniform4f(cLoc, color.r, color.g, color.b, 0.5f);
    
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
        
    vertexbufferChangeAlpha(colors, 1.0);
//    glUniform4f(cLoc, color.r, color.g, color.b, 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    
    free(colors.vertices);
}

void GLES2DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
    glUseProgram(this->program);
    
	vertexbuffer buffer = verticesForCircle(center, radius);
    vertexbuffer colors = colorBufferForColor(color, 0.5, buffer.count);
    
//    glUniform4f(glGetUniformLocation(this->program, "color"), color.r, color.g, color.b, 0.5f);
	enableAttribArrays(buffer, colors);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, buffer.count);
    cleanUpBuffers(buffer, colors);
}

void GLES2DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
    glUseProgram(this->program);
    vertexbuffer buffer = verticesForCircle(center, radius);
    vertexbuffer colors = colorBufferForColor(color, 0.5, buffer.count);
    
//    GLuint cLoc = glGetUniformLocation(this->program, "color");
//    glUniform4f(cLoc, color.r, color.g, color.b, 0.5f);
	enableAttribArrays(buffer, colors);
	glDrawArrays(GL_TRIANGLE_FAN, 0, buffer.count);
    
//    glUniform4f(cLoc, color.r, color.g, color.b, 1.0f);
    vertexbufferChangeAlpha(colors, 1.0);
	glDrawArrays(GL_LINE_LOOP, 0, buffer.count);
    
    cleanUpBuffers(buffer, colors);
	
	// Draw the axis line
	DrawSegment(center,center+radius*axis,color);
}

void GLES2DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color) {
    glUseProgram(this->program);
//    glUniform4f(glGetUniformLocation(this->program, "color"), color.r, color.g, color.b, 1.0f);
    
	GLfloat	glVertices[] = {
		p1.x,p1.y,p2.x,p2.y
	};
    
    vertexbuffer colors = colorBufferForColor(color, 1.0, 2);
    
    glVertexAttribPointer(GLProgramAttributePosition, 2, GL_FLOAT, 0, 0, glVertices);
	glEnableVertexAttribArray(GLProgramAttributePosition);
    glVertexAttribPointer(GLProgramAttributeColor, 4, GL_FLOAT, 0, 0, colors.vertices);
    glEnableVertexAttribArray(GLProgramAttributeColor);
    
	glDrawArrays(GL_LINES, 0, 2);
    
    free(colors.vertices);
}

void GLES2DebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.position, p2;
	const float32 k_axisScale = 0.4f;
    
	p2 = p1 + k_axisScale * xf.R.col1;
	DrawSegment(p1,p2,b2Color(1,0,0));
	
	p2 = p1 + k_axisScale * xf.R.col2;
	DrawSegment(p1,p2,b2Color(0,1,0));
}

void GLES2DebugDraw::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
	glColor4f(color.r, color.g, color.b,1);
	glPointSize(size);
	GLfloat				glVertices[] = {
		p.x,p.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_POINTS, 0, 1);
	glPointSize(1.0f);
}

void GLES2DebugDraw::DrawString(int x, int y, const char *string, ...)
{
    
	/* Unsupported as yet. Could replace with bitmap font renderer at a later date */
}

void GLES2DebugDraw::DrawAABB(b2AABB* aabb, const b2Color& c)
{
	
	glColor4f(c.r, c.g, c.b,1);
    
	GLfloat				glVertices[] = {
		aabb->lowerBound.x, aabb->lowerBound.y,
		aabb->upperBound.x, aabb->lowerBound.y,
		aabb->upperBound.x, aabb->upperBound.y,
		aabb->lowerBound.x, aabb->upperBound.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_LINE_LOOP, 0, 8);
}

#pragma -
#pragma GLES1DEBUGDRAW

/*
 * Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
 *
 * iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include <cstdio>
#include <cstdarg>

#include <cstring>

void GLES1DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glColor4f(color.r, color.g, color.b,1);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void GLES1DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	
	glColor4f(color.r, color.g, color.b,0.5f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
	
	glColor4f(color.r, color.g, color.b,1);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void GLES1DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
	GLfloat				glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x;
		glVertices[i*2+1]=v.y;
		theta += k_increment;
	}
	
	glColor4f(color.r, color.g, color.b,1);
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

void GLES1DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
	GLfloat				glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x;
		glVertices[i*2+1]=v.y;
		theta += k_increment;
	}
	
	glColor4f(color.r, color.g, color.b,0.5f);
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
	glColor4f(color.r, color.g, color.b,1);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
	
	// Draw the axis line
	DrawSegment(center,center+radius*axis,color);
}

void GLES1DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	glColor4f(color.r, color.g, color.b,1);
	GLfloat				glVertices[] = {
		p1.x,p1.y,p2.x,p2.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_LINES, 0, 2);
}

void GLES1DebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.position, p2;
	const float32 k_axisScale = 0.4f;
    
	p2 = p1 + k_axisScale * xf.R.col1;
	DrawSegment(p1,p2,b2Color(1,0,0));
	
	p2 = p1 + k_axisScale * xf.R.col2;
	DrawSegment(p1,p2,b2Color(0,1,0));
}

void GLES1DebugDraw::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
	glColor4f(color.r, color.g, color.b,1);
	glPointSize(size);
	GLfloat				glVertices[] = {
		p.x,p.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_POINTS, 0, 1);
	glPointSize(1.0f);
}

void GLES1DebugDraw::DrawString(int x, int y, const char *string, ...)
{
    
	/* Unsupported as yet. Could replace with bitmap font renderer at a later date */
}

void GLES1DebugDraw::DrawAABB(b2AABB* aabb, const b2Color& c)
{
	
	glColor4f(c.r, c.g, c.b,1);
    
	GLfloat				glVertices[] = {
		aabb->lowerBound.x, aabb->lowerBound.y,
		aabb->upperBound.x, aabb->lowerBound.y,
		aabb->upperBound.x, aabb->upperBound.y,
		aabb->lowerBound.x, aabb->upperBound.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_LINE_LOOP, 0, 8);
	
}