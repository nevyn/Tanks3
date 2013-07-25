#define WORLD_WRITABLE_MODEL 1
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
        _map = [NSMutableArray array];
        for(int i = 0; i < arenaWidth*arenaHeight; i++)
            [_map addObject:@0];
    }
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"levelSize": @{@"width":@(self.levelSize.width), @"height": @(self.levelSize.height)},
		@"map": self.map,
	});
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"levelSize", ^(id o) {
        self.levelSize = CGSizeMake([o[@"width"] floatValue], [o[@"height"] floatValue]);
    });
    WorldIf(rep, @"map", ^(id o) { self.map = o; });
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
		if (tile > TankLevelMapTileTypeFloor) {
			
			SKPhysicsBody *tileBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(((i%arenaWidth)*tileWidth), (floor(i/arenaWidth)*tileHeight), tileWidth, tileHeight)];
            tileBody.categoryBitMask = TankGamePhysicsCategoryWall | TankGamePhysicsCategoryMakesBulletBounce;
            if(tile == TankLevelMapTileTypeBreakable)
                tileBody.categoryBitMask |= TankGamePhysicsCategoryDestructableWall;
            else if(tile == TankLevelMapTileTypeHole)
                tileBody.categoryBitMask = TankGamePhysicsCategoryHole;
			tileBody.restitution = 0;
            tileBody.friction = 1;
			[world addBody:tileBody];
		}
	}
}

@end
