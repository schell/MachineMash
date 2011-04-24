//
//  ShaderColorVarying.fsh
//  MachineMash
//
//  Created by Schell Scivally on 4/2/11.
//  Copyright 2011 ModMash. All rights reserved.
//

varying lowp vec4 colorVarying;

void main() {
    gl_FragColor = colorVarying;
}
