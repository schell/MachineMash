//
//  ShaderColorVarying.fsh
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

varying lowp vec4 colorVarying;

uniform lowp float alpha;

void main() {
    gl_FragColor = vec4(colorVarying.rgb,colorVarying.a*alpha);
}
