//
//  Shader.vsh
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

attribute vec2 position;

uniform mat4 projection;
uniform mat4 cameraview;

void main() {
    
    gl_Position = projection * cameraview * vec4(position, 0.0, 1.0);
}
