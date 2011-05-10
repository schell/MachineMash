//
//  GLESDebugDraw.cpp
//  MachineMash
//
//  Created by Schell Scivally on 4/3/11.
//  Copyright 2011 ModMash. All rights reserved.
//

#include "GLESDebugDraw.h"
#include "VertexBufferObject.h"
#include "Geometry.h"
#include "Color.h"
#include "GLProgram.h"

#define PTM_RATIO 32.0f

#pragma -
#pragma Helpers

#pragma -
#pragma GLESDEBUGDRAW

GLESDebugDraw::GLESDebugDraw() {}
GLESDebugDraw::~GLESDebugDraw() {}

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

void GLESDebugDraw::DrawShape(b2Fixture* fixture, const b2Transform& xf, const b2Color& color) {
	switch (fixture->GetType())
	{
        case b2Shape::e_circle:
		{
			b2CircleShape* circle = (b2CircleShape*)fixture->GetShape();
            
			b2Vec2 center = b2Mul(xf, circle->m_p);
			float32 radius = circle->m_radius;
			b2Vec2 axis = xf.R.col1;
            
			this->DrawSolidCircle(center, radius, axis, color);
		}
            break;
            
        case b2Shape::e_polygon:
		{
			b2PolygonShape* poly = (b2PolygonShape*)fixture->GetShape();
			int32 vertexCount = poly->m_vertexCount;
			b2Assert(vertexCount <= b2_maxPolygonVertices);
			b2Vec2 vertices[b2_maxPolygonVertices];
            
			for (int32 i = 0; i < vertexCount; ++i)
			{
				vertices[i] = b2Mul(xf, poly->m_vertices[i]);
			}
            
			this->DrawSolidPolygon(vertices, vertexCount, color);
		}
            break;
        default:
            break;
	}
}

void GLESDebugDraw::DrawJoint(b2Joint* joint) {
	b2Body* bodyA = joint->GetBodyA();
	b2Body* bodyB = joint->GetBodyB();
	const b2Transform& xf1 = bodyA->GetTransform();
	const b2Transform& xf2 = bodyB->GetTransform();
	b2Vec2 x1 = xf1.position;
	b2Vec2 x2 = xf2.position;
	b2Vec2 p1 = joint->GetAnchorA();
	b2Vec2 p2 = joint->GetAnchorB();
    
	b2Color color(1.0, 0.0, 1.0);
    
	switch (joint->GetType()) {
        case e_distanceJoint:
            this->DrawSegment(p1, p2, color);
            break;
            
        case e_pulleyJoint:
		{
			b2PulleyJoint* pulley = (b2PulleyJoint*)joint;
			b2Vec2 s1 = pulley->GetGroundAnchorA();
			b2Vec2 s2 = pulley->GetGroundAnchorB();
			this->DrawSegment(s1, p1, color);
			this->DrawSegment(s2, p2, color);
			this->DrawSegment(s1, s2, color);
		}
            break;
            
        case e_mouseJoint:
            // don't draw this
            break;
            
        default:
            this->DrawSegment(x1, p1, color);
            this->DrawSegment(p1, p2, color);
            this->DrawSegment(x2, p2, color);
	}
}

#pragma -
#pragma GLES2DEBUGDRAW

void drawPolygonES2(const b2Vec2* vertices, int32 vertexCount, Color color, GLenum drawMode, GLuint program) {
    VertexBufferObject vbo("polygon");
    vbo.drawMode = drawMode;
    vbo.shaderProgramName = program;
    std::vector<float> verts;
    for (int i = 0; i<vertexCount; i++) {
        verts.push_back(vertices[i].x); 
        verts.push_back(vertices[i].y);
    }
    vbo.addAttributeData(&verts, 2, GLProgramAttributePosition);
    std::vector<float> colorBuffer = Color::colorBuffer(&color, vbo.vertexCount());
    vbo.addAttributeData(&colorBuffer, 4, GLProgramAttributeColor);
    vbo.draw();
    vbo.unload();
}

void GLES2DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color) {
    Color c(color.r, color.g, color.b, 1.0);
    drawPolygonES2(vertices, vertexCount, c, GL_LINE_LOOP, this->program);
}

void GLES2DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color) {
    Color c(color.r, color.g, color.b, 0.5);
    drawPolygonES2(vertices, vertexCount, c, GL_TRIANGLE_FAN, this->program);
    c.a = 1.0;
    drawPolygonES2(vertices, vertexCount, c, GL_LINE_LOOP, this->program);
}

void drawCircleES2(const b2Vec2& center, float32 radius, Color color, GLenum drawMode, GLuint program) {
    VertexBufferObject vbo("circle");
    vbo.drawMode = drawMode;
    vbo.shaderProgramName = program;
    std::vector<float> verts = Geometry::circle(center.x, center.y, radius, 28);
    vbo.addAttributeData(&verts, 2, GLProgramAttributePosition);
    std::vector<float> colors = Color::colorBuffer(&color, vbo.vertexCount());
    vbo.addAttributeData(&colors, 4, GLProgramAttributeColor);
    vbo.draw();
    vbo.unload();
}

void GLES2DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color) {
    Color c(color.r, color.g, color.b, 1.0);
    drawCircleES2(center, radius, c, GL_LINE_LOOP, this->program);
}

void GLES2DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color) {
    Color c(color.r, color.g, color.b, 0.5);
    drawCircleES2(center, radius, c, GL_TRIANGLE_FAN, this->program);
    c.a = 1.0;
    drawCircleES2(center, radius, c, GL_LINE_LOOP, this->program);
    this->DrawSegment(center, b2Vec2(center.x+radius*axis.x, center.y+radius*axis.y), color);
}

void GLES2DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color) {
    VertexBufferObject vbo("segment");
    vbo.drawMode = GL_LINES;
    vbo.shaderProgramName = this->program;
    float vertData[] = {p1.x,p1.y,p2.x,p2.y};
    std::vector<float> verts(vertData, vertData+4);
    vbo.addAttributeData(&verts, 2, GLProgramAttributePosition);
    Color c(color.r, color.g, color.b, 1.0);
    std::vector<float> colorBuffer = Color::colorBuffer(&c, vbo.vertexCount());
    vbo.addAttributeData(&colorBuffer, 4, GLProgramAttributeColor);
    vbo.draw();
    vbo.unload();
}

void GLES2DebugDraw::DrawTransform(const b2Transform& xf) {
	b2Vec2 p1 = xf.position, p2;
	const float32 k_axisScale = 0.4f;
    
	p2 = p1 + k_axisScale * xf.R.col1;
	DrawSegment(p1,p2,b2Color(1,0,0));
	
	p2 = p1 + k_axisScale * xf.R.col2;
	DrawSegment(p1,p2,b2Color(0,1,0));
}

void GLES2DebugDraw::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color) {
	glColor4f(color.r, color.g, color.b,1);
	glPointSize(size);
	GLfloat	glVertices[] = {p.x,p.y};
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