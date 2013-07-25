#import "TankLevelMap.h"
#import "TankTypes.h"
#import "SKPhysics+Private.h"

@implementation TankLevelMap
- (id)init
{
    if(self = [super init]) {
    
		float w = 660, h = 480;
		_levelSize = CGSizeMake(w, h);
        
        // Original maps are 22 x 16 tiles, so ours are too!
        _map = [@[
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @1, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @1,
            @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0
        ] mutableCopy];
    }
    return self;
}

+ (NSSet*)observableToManyAttributes
{
    NSMutableSet *s = [[super observableToManyAttributes] mutableCopy];
    [s removeObject:@"map"];
    return s;
}

- (void)addWallsToPhysics:(SKPhysicsWorld*)world
{
    CGPathRef path = CGPathCreateWithRect((CGRect){.size=self.levelSize}, NULL);
    SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
    body.categoryBitMask = TankGamePhysicsCategoryWall | TankGamePhysicsCategoryMakesBulletBounce;
    body.restitution = 0;
    body.friction = 1;

    CGPathRelease(path);
    [world addBody:body];
	
	float tileWidth = _levelSize.width/arenaWidth;
	float tileHeight = _levelSize.height/arenaHeight;
	
	for (int i = 0; i < _map.count; i++) {
		
		int tile = [_map[i] intValue];
		if (tile != 0) {
			
			SKPhysicsBody *tileBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(((i%arenaWidth)*tileWidth), (floor(i/arenaWidth)*tileHeight), tileWidth, tileHeight)];
            tileBody.categoryBitMask = TankGamePhysicsCategoryWall | TankGamePhysicsCategoryMakesBulletBounce;
			tileBody.restitution = 0;
            tileBody.friction = 1;
			[world addBody:tileBody];
		}
	}
}

@end
