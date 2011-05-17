//
//  TexShader.vsh
//  MachineMash
//
//  Created by Schell Scivally on 2/21/11.
//  Copyright 2011 ModMash. All rights reserved.
//
attribute vec2 position;
attribute vec2 texcoord;

uniform mat4 projection;
uniform mat4 cameraview;
uniform mat4 modelview;

varying vec2 vTexcoord;

void main() {
	vTexcoord = texcoord;
    gl_Position = projection * cameraview * modelview * vec4(position, 0.0, 1.0);
}
