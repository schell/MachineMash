//
//  TexShader.fsh
//  MachineMash
//
//  Created by Schell Scivally on 2/28/11.
//  Copyright 2011 ModMash. All rights reserved.
//
varying highp vec2 vTexcoord;

uniform sampler2D sampler;
uniform mediump vec4 color;
uniform bool colored;

void main() {
	highp vec4 bitmapColor = texture2D(sampler, vTexcoord);
	if (colored) {
        //highp float rms = sqrt( (pow(1.0-bitmapColor.r, 2.0) + pow(1.0-bitmapColor.g, 2.0) + pow(1.0-bitmapColor.b, 2.0))/3.0 );
        gl_FragColor = vec4(color.rgb, bitmapColor.a*color.a);
    } else {
        gl_FragColor = bitmapColor;
    }
}