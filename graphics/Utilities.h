//
//  Utilities.h
//  MachineMash
//
//  Created by Schell Scivally on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __MOD_MASH_UTILITIES_CLASS__
#define __MOD_MASH_UTILITIES_CLASS__

#include <string>
#include <vector>

class Utilities {
public:
    static std::vector<std::string> ls(std::string dir);
    static std::string getFileAsString(std::string file);
    static std::string applicationBundleLocation;
};

#endif