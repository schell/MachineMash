//
//  GLESDebugDraw.h
//  MachineMash
//
//  Created by Schell Scivally on 4/3/11.
//  Copyright 2011 ModMash. All rights reserved.

#ifndef GLESDEBUG
#define GLESDEBUG

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <Box2D/Box2D.h>
#include "Graphics.h"

struct b2AABB;

class GLESDebugDraw {
public:
	GLESDebugDraw();
	~GLESDebugDraw();
    
    void DrawOrigin();
    void DrawShape(b2Fixture* fixture, const b2Transform& xf, const b2Color& color);
    void DrawJoint(b2Joint* joint);
    
	virtual void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)=0;
	virtual void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)=0;
	virtual void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)=0;
	virtual void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)=0;
	virtual void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)=0;
	virtual void DrawTransform(const b2Transform& xf)=0;
    virtual void DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)=0;
    virtual void DrawString(int x, int y, const char* string, ...)=0; 
    virtual void DrawAABB(b2AABB* aabb, const b2Color& color)=0;
    
    float screenWidth;
    float screenHeight;
};

class GLES1DebugDraw : public GLESDebugDraw {
public:
	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);
	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);
	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);
	void DrawTransform(const b2Transform& xf);
    void DrawPoint(const b2Vec2& p, float32 size, const b2Color& color);
    void DrawString(int x, int y, const char* string, ...); 
    void DrawAABB(b2AABB* aabb, const b2Color& color);
};

// GLES2 modified by Schell Scivally
class GLES2DebugDraw : public GLESDebugDraw {
public:
    ShaderProgram* shaderProgram();
    GLES2DebugDraw();
	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);
	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);
	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);
	void DrawTransform(const b2Transform& xf);
    void DrawPoint(const b2Vec2& p, float32 size, const b2Color& color);
    void DrawString(int x, int y, const char* string, ...); 
    void DrawAABB(b2AABB* aabb, const b2Color& color);
};

#endif
