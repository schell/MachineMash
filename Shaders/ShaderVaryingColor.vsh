//
//  ShaderVaryingColor.vsh
//  MachineMash
//
//  Created by Schell Scivally on 4/7/11.
//  Copyright 2011 ModMash. All rights reserved.
//

attribute vec2 position;
attribute vec4 color;

uniform mat4 projection;
uniform mat4 cameraview;
uniform mat4 modelview;

varying vec4 colorVarying;

void main() {
    colorVarying = color;
    gl_Position = projection * cameraview * modelview * vec4(position, 0.0, 1.0);
}