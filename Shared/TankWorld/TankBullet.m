#define WORLD_WRITABLE_MODEL 1
#import "TankBullet.h"
#import "TankTypes.h"

@implementation TankBullet
- (id)init
{
    if(self = [super init]) {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:2];
        self.physicsBody.angularDamping = 1000;
        self.physicsBody.categoryBitMask = TankGamePhysicsCategoryBullet | TankGamePhysicsCategoryMakesBulletExplode;
        self.physicsBody.contactTestBitMask = TankGamePhysicsCategoryBullet | TankGamePhysicsCategoryWall | TankGamePhysicsCategoryDestructableWall | TankGamePhysicsCategoryTank | TankGamePhysicsCategoryMine;
        self.speed = TankBulletStandardSpeed;
    }
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
		@"collisionTTL": @(_collisionTTL),
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"collisionTTL", ^(id o) { self.collisionTTL = [o intValue]; });
}

- (void)updatePhysicsFromProperties
{
    [super updatePhysicsFromProperties];
    self.physicsBody.velocity = [[Vector2 vectorWithX:0 y:1] vectorByRotatingByRadians:self.rotation].point;
}

- (void)applyForces;
{
//    self.acceleration = [[[Vector2 vectorWithX:0 y:1] vectorByRotatingByRadians:self.rotation] vectorByMultiplyingWithScalar:self.speed];
    Vector2 *oldV = [Vector2 vectorWithPoint:self.physicsBody.velocity];
    if(oldV.length == 0)
        oldV = [Vector2 vectorWithX:0 y:1];
    Vector2 *v = [[oldV normalizedVector] vectorByMultiplyingWithScalar:self.speed];
    self.physicsBody.velocity = v.point;
}

- (void)collidedWithBody:(SKPhysicsBody *)body entity:(WorldEntity *)other inGame:(TankGame *)game
{
    if([body categoryBitMask] & TankGamePhysicsCategoryMakesBulletBounce) {
        if(--self.collisionTTL == 0) {
            [self removeFromParent];
            return;
        }
        
        // todo: make new velocity for bullet
        
    } else if([body categoryBitMask] & TankGamePhysicsCategoryMakesBulletExplode) {
        [self removeFromParent];
    }
}

@end
