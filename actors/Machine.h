//
//  Machine.h
//  MachineMash
//
//  Created by Schell Scivally on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>
#include <vector>

#define HP_SHOW_TIME 2.0

typedef enum {
    MachineMaterialNone,
    MachineMaterialPlastic,
    MachineMaterialWood,
    MachineMaterialMetal
} MachineMaterial;

@interface Machine : NSObject {
    b2Body* _cpu;
    NSMutableArray* _controls;
    std::vector<b2Body*> _bodies;
    std::vector<b2Joint*> _joints;
}
- (id)initWithWorld:(b2World*)world;
- (b2Body*)cpu;
- (float32)densityOf:(MachineMaterial)material;
@end
