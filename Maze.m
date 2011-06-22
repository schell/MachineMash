//
//  Maze.m
//  CubicPlutonia
//
//  Created by Schell Scivally on 1/9/11.
//  Copyright 2011 SlaughterBalloonSoftware. All rights reserved.
//

#import "Maze.h"
#import "NSString+Session.h"

@implementation Cell
@synthesize north,south,east,west,valid,x,y;

#pragma mark -
#pragma mark Lifecycle

- (id)init {
	self = [super init];
	self.north = WALL_CLOSED;
	self.east = WALL_CLOSED;
	self.south = WALL_CLOSED;
	self.west = WALL_CLOSED;
	self.valid = YES;
	self.x = 0;
	self.y = 0;
	return self;
}

+ (Cell*)closedCell {
	return [[[Cell alloc] init] autorelease];
}

+ (int)oppositeDirectionOf:(int)direction {
	switch (direction) {
		case NORTH:
			return SOUTH;
		case EAST:
			return WEST;
		case SOUTH:
			return NORTH;
		case WEST:
			return EAST;
	}
	[NSException raise:@"could not get opposite direction" format:@"%i is not a valid direction",direction];
	return -1;
}

@end

@implementation Maze
@synthesize grid;

#pragma mark -
#pragma mark Lifecycle

- (id)initWithWidth:(int)w andHeight:(int)h {
	self = [super init];
	_grid = [[NSMutableArray array] retain];
	for (int i = 0; i < w; i++) {
		NSMutableArray* column = [NSMutableArray array];
		[_grid addObject:column];
		for (int j = 0; j < h; j++) {
			Cell* cell = [Cell closedCell];
			cell.x = i;
			cell.y = j;
			[column addObject:cell];
		}
	}
	return self;
}

#pragma mark -
#pragma mark Infos

- (int)width {
	return [_grid count];
}

- (int)height {
	return [[_grid objectAtIndex:0] count];
}

#pragma mark -
#pragma mark Utility

+ (NSArray*)randomizedDirections {
	NSMutableArray* directions = [[NSMutableArray array] retain];
	for (int i = 0; i < 4; i++) {
		NSNumber* direction = [NSNumber numberWithInt:i];
		[directions addObject:direction];
	}
	srand(clock());
	for (int i = 0; i < 4; i++) {
		int ndx = rand()%4;
		NSNumber* switcher = [directions objectAtIndex:i];
		[directions replaceObjectAtIndex:i withObject:[directions objectAtIndex:ndx]];
		[directions replaceObjectAtIndex:ndx withObject:switcher];
	}
	NSLog(@"directions:\n%@",directions);
	return [directions autorelease];
}

#pragma mark -
#pragma mark Carving

- (void)openWall:(int)direction forCellAtX:(int)x Y:(int)y {
	int dx = x;
	int dy = y;
	Cell* cell = [self getCellAtRow:x inColumn:y];
	switch (direction) {
		case NORTH:
			cell.north = WALL_OPEN;
			dy -= 1;
			break;
		case EAST:
			cell.east = WALL_OPEN;
			dx += 1;
			break;
		case SOUTH:
			cell.south = WALL_OPEN;
			dy += 1;
			break;
		case WEST:
			cell.west = WALL_OPEN;
			dx += 1;
			break;
	}
	Cell* adjacentCell = [self getCellAtRow:dx inColumn:dy];
	if (adjacentCell != nil) {
		[self openWall:direction forCellAtX:dx Y:dy];
	}
}

- (void)closeWall:(int)direction forCellAtX:(int)x Y:(int)y {
	int dx = x;
	int dy = y;
	Cell* cell = [self getCellAtRow:x inColumn:y];
	switch (direction) {
		case NORTH:
			cell.north = WALL_CLOSED;
			dy -= 1;
			break;
		case EAST:
			cell.east = WALL_CLOSED;
			dx += 1;
			break;
		case SOUTH:
			cell.south = WALL_CLOSED;
			dy += 1;
			break;
		case WEST:
			cell.west = WALL_CLOSED;
			dx -= 1;
			break;
	}
	Cell* adjacentCell = [self getCellAtRow:dx inColumn:dy];
	if (adjacentCell != nil) {
		[self closeWall:direction forCellAtX:dx Y:dy];
	}
}

- (void)openAllWallsForCellAtRow:(int)x inColumn:(int)y {
	Cell* cell = [self getCellAtRow:x inColumn:y];
	if (cell == nil) {
		return;
	}
	cell.north = WALL_OPEN;
	cell.east = WALL_OPEN;
	cell.south = WALL_OPEN;
	cell.west = WALL_OPEN;
	int directions[] = {NORTH,EAST,SOUTH,WEST};
	for (int i = 0; i < 4; i++) {
		Cell* adjacentCell = [self getCellAdjacentToCell:cell byDirection:directions[i]];
		if (adjacentCell != nil) {
			adjacentCell.north = WALL_OPEN;
			adjacentCell.east = WALL_OPEN;
			adjacentCell.south = WALL_OPEN;
			adjacentCell.west = WALL_OPEN;
		}
	}
}

- (Cell*)getCellAtRow:(int)x inColumn:(int)y {
	int w = [self width];
	int h = [self height];
	if (x >= w || x < 0 || y >= h || y < 0) {
		return nil;
	}
	return [[_grid objectAtIndex:x] objectAtIndex:y];
}

- (Cell*)getCellAdjacentToCell:(Cell*)cell byDirection:(int)direction {
	switch (direction) {
		case NORTH:
			return [self getCellAtRow:cell.x inColumn:cell.y-1];
		case EAST:
			return [self getCellAtRow:cell.x+1 inColumn:cell.y];
		case SOUTH:
			return [self getCellAtRow:cell.x inColumn:cell.y+1];
		case WEST:
			return [self getCellAtRow:cell.x-1 inColumn:cell.y];
	}
	return nil;
}

- (void)carvePassagesFromX:(int)x Y:(int)y {
	int w = [self width];
	int h = [self height];
	Cell* cell = [self getCellAtRow:x inColumn:y];
	if (cell == nil) {
		[NSException raise:@"cell does not exist" format:@"%i %i is out of bounds",x,y];
	}
	int visitedCells = 1;
	NSMutableArray* path = [[NSMutableArray arrayWithObject:cell] retain];
	// until we've visited every cell
	while (visitedCells < w*h) {
		// find an adjacent cell that we can carve
		NSMutableArray* directions = [NSMutableArray arrayWithArray:[Maze randomizedDirections]];
		int direction;
		Cell* adjacentCell = nil;
		while ([directions count] > 0 && (adjacentCell == nil || !adjacentCell.valid)) {
			direction = [[directions objectAtIndex:0] intValue];
			[directions removeObjectAtIndex:0];
			adjacentCell = [self getCellAdjacentToCell:cell byDirection:direction];
		}
		// if we still don't have a valid cell
		if (adjacentCell == nil || !adjacentCell.valid) {
			[path removeLastObject];
			cell = [path lastObject];
			continue;
			// back up to the last cell and continue from there
		}
		switch (direction) {
			case NORTH:
				cell.north = WALL_OPEN;
				adjacentCell.south = WALL_OPEN;
			break;
			case EAST:
				cell.east = WALL_OPEN;
				adjacentCell.west = WALL_OPEN;
			break;
			case SOUTH:
				cell.south = WALL_OPEN;
				adjacentCell.north = WALL_OPEN;
			break;
			case WEST:
				cell.west = WALL_OPEN;
				adjacentCell.east = WALL_OPEN;
			break;
		}
		cell.valid = NO;
		adjacentCell.valid = NO;
		cell = adjacentCell;
		[path addObject:cell];
		visitedCells++;
	}
}

#pragma mark -
#pragma mark Mesh

+ (Mesh*)meshFromCell:(Cell*)room {
	Mesh* roomMesh = [[Mesh alloc] init];
	roomMesh.name = @"";

	if (room.north == WALL_CLOSED) {
		Mesh* north = [[[Mesh alloc] init] autorelease];
		north.name = @"Cube_Back";
		[roomMesh.children addObject:north];
	}
	if (room.south == WALL_CLOSED) {
		Mesh* south = [[[Mesh alloc] init] autorelease];
		south.name = @"Cube_Front";
		[roomMesh.children addObject:south];
	}
	if (room.east == WALL_CLOSED) {
		Mesh* east = [[[Mesh alloc] init] autorelease];
		east.name = @"Cube_Right";
		[roomMesh.children addObject:east];
	}
	if (room.west == WALL_CLOSED) {
		Mesh* west = [[[Mesh alloc] init] autorelease];
		west.name = @"Cube_Left";
		[roomMesh.children addObject:west];
	}
	return [roomMesh autorelease];
}

- (Mesh*)generateMesh {
	Mesh* maze = [[Mesh alloc] init];
	int w = [self width];
	int h = [self height];
	for (int i = 0; i < w; i++) {
		NSArray* column = [_grid objectAtIndex:i];
		for (int j = 0; j < h; j++) {
			Cell* room = (Cell*)[column objectAtIndex:j];
			Mesh* roomMesh = [Maze meshFromCell:room];
			roomMesh.name = [NSString stringWithFormat:@"room %i %i",i,j];
			roomMesh.hasVertices = NO;
			[roomMesh.matrix moveLeft:-w/2 + i + 0.5];
			[roomMesh.matrix moveUp:-h/2 + j + 0.5];
			[roomMesh.matrix scale:0.98 y:0.98 z:0.98];
			[maze.children addObject:roomMesh];
		}
	}
	return [maze autorelease];
}
@end
