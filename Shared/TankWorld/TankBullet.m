#define WORLD_WRITABLE_MODEL 1
#import "TankBullet.h"
#import "TankTypes.h"
#import "SKPhysics+Private.h"

@implementation TankBullet
{
    __weak SKPhysicsBody *_lastBounce;
}
- (id)init
{
    if(self = [super init]) {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:2];
//        self.physicsBody.angularDamping = 1000;
        self.physicsBody.restitution = 1.0;
        self.physicsBody.friction = 1.0;
        self.physicsBody.usesPreciseCollisionDetection = YES;
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
    self.physicsBody.velocity = [[Vector2 vectorWithX:0 y:self.speed] vectorByRotatingByRadians:self.rotation].point;
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

- (void)updatePropertiesFromPhysics
{
    [super updatePropertiesFromPhysics];
    self.rotation = [[Vector2 vectorWithPoint:self.physicsBody.velocity] angle] - M_PI_2;
}

- (void)collided:(SKPhysicsContact*)contact withBody:(SKPhysicsBody*)body entity:(WorldEntity*)other inGame:(TankGame*)game
{
    if([body categoryBitMask] & TankGamePhysicsCategoryMakesBulletBounce) {
        if(body == _lastBounce)
            return;
        _lastBounce = body;
        
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
