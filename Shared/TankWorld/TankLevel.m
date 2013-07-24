#define WORLD_WRITABLE_MODEL 1
#import "TankLevel.h"
#import "BNZLine.h"
#import "SKPhysics+Private.h"

@implementation TankLevel
- (id)init
{
	if(self = [super init]) {
		_bullets = [NSMutableArray new];
		float w = 660, h = 480;
		_levelSize = CGSizeMake(w, h);
        
        // Original maps are 22 x 16 tiles, so ours are too!
        _map = [@[
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @1, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0, @1,
            @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0
        ] mutableCopy];
	}
	return self;
}

- (void)addWallsToPhysics:(SKPhysicsWorld*)world
{
    CGPathRef path = CGPathCreateWithRect((CGRect){.size=self.levelSize}, NULL);
    SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
    CGPathRelease(path);
    [world addBody:body];
	
	float tileWidth = _levelSize.width/arenaWidth;
	float tileHeight = _levelSize.height/arenaHeight;
	
	for (int i = 0; i < _map.count; i++) {
		
		int tile = [_map[i] intValue];
		if (tile != 0) {
			
			SKPhysicsBody *tileBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(tileWidth, tileHeight)];
			tileBody.position = CGPointMake(((i%arenaWidth)*tileWidth)+tileWidth/2, (floor(i/arenaWidth)*tileHeight)+tileHeight/2);
			tileBody.mass = 100000;
			[world addBody:tileBody];
		}
	}
}

+ (NSSet*)observableToManyAttributes
{
    NSMutableSet *s = [[super observableToManyAttributes] mutableCopy];
    [s removeObject:@"map"];
    [s removeObject:@"walls"];
    return s;
}
@end
