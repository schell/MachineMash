//
//  Shader.vsh
//  Untitled
//
//  Created by Schell Scivally on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
uniform mat4 projection;
uniform mat4 modelview;

attribute vec2 position;
attribute vec2 texcoord;

varying vec2 vTexcoord;

void main()
{
    gl_Position = projection * modelview * vec4(position, 0.0, 1.0);
	vTexcoord = texcoord;
}
