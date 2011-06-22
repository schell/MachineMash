//
//  Maze.h
//  CubicPlutonia
//
//  Created by Schell Scivally on 1/9/11.
//  Copyright 2011 SlaughterBalloonSoftware. All rights reserved.
//
#ifndef __MOD_MASH_MAZE_CLASS__
#define __MOD_MASH_MAZE_CLASS__

#define MAZE_RECURSIVE_BACKTRACKING 0
#define WALL_OPEN YES
#define WALL_CLOSED NO

enum DIRECTION {
	NORTH,
	EAST,
	SOUTH,
	WEST
};

#import <Foundation/Foundation.h>
#import "TV3D.h"

@interface Cell : NSObject {
	BOOL north;
	BOOL east;
	BOOL south;
	BOOL west;
	BOOL valid;
	int x;
	int y;
}
+ (Cell*)closedCell;
+ (int)oppositeDirectionOf:(int)direction;
@property (readwrite,assign) BOOL north;
@property (readwrite,assign) BOOL east;
@property (readwrite,assign) BOOL south;
@property (readwrite,assign) BOOL west;
@property (readwrite,assign) BOOL valid;
@property (readwrite,assign) int x;
@property (readwrite,assign) int y;
@end

@interface Maze : NSObject {
	NSMutableArray* _grid;
	NSMutableArray* _visitedCells;
}
+ (Mesh*)meshFromCell:(Cell*)room;
+ (NSArray*)randomizedDirections;
- (id)initWithWidth:(int)width andHeight:(int)height;
- (int)width;
- (int)height;
- (void)carvePassagesFromX:(int)x Y:(int)y;
- (Mesh*)generateMesh;
- (void)openWall:(int)direction forCellAtX:(int)x Y:(int)y;
- (void)closeWall:(int)direction forCellAtX:(int)x Y:(int)y;
- (void)openAllWallsForCellAtRow:(int)x inColumn:(int)y;
- (Cell*)getCellAtRow:(int)x inColumn:(int)y;
- (Cell*)getCellAdjacentToCell:(Cell *)cell byDirection:(int)direction;
@property (readonly,nonatomic) NSArray* grid;
@end
#endif