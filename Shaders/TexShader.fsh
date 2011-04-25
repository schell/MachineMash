//
//  Shader.fsh
//  Untitled
//
//  Created by Schell Scivally on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying highp vec2 vTexcoord;

uniform sampler2D sampler;
uniform lowp vec4 color;

void main()
{
	lowp vec4 bitmapColor = texture2D(sampler, vTexcoord);
	if (bitmapColor.r == 1.0 && bitmapColor.g == 1.0 && bitmapColor.g == 1.0) {
		gl_FragColor = vec4(0.0,0.0,0.0,0.0);
	} else {
		gl_FragColor = color;
	}
}
