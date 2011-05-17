//
//  Utilities.cpp
//  MachineMash
//
//  Created by Schell Scivally on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Utilities.h"
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

string Utilities::applicationBundleLocation = "/";

vector<string> Utilities::ls(string dir) {
    vector<string> files;
    DIR* dp;
    struct dirent* dirp;
    if((dp  = opendir(dir.c_str())) == NULL) {
        cout << "Error(" << errno << ") opening " << dir << endl;
        return files;
    }
    
    while ((dirp = readdir(dp)) != NULL) {
        files.push_back(string(dirp->d_name));
    }
    closedir(dp);
    return files;
}

string Utilities::getFileAsString(string file) {
    string base = Utilities::applicationBundleLocation;
    base += "/";
    base += file;
    
    ifstream t(base.c_str(), ifstream::in);
    stringstream buffer;
    buffer << t.rdbuf();
    return buffer.str();
}