#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankMine.h"
#import "TankTypes.h"
#import "BNZLine.h"
#import "SKPhysics+Private.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		self.position = [Vector2 vectorWithX:10 y:10];
        self.moveIntent = [Vector2 vectorWithX:0 y:0];
        
        self.speed = TankMaxSpeed;
		
        _aimingAt = [Vector2 zero];

        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:TankCollisionRadius];
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.categoryBitMask = TankGamePhysicsCategoryTank | TankGamePhysicsCategoryMakesBulletExplode;
        self.physicsBody.contactTestBitMask = TankGamePhysicsCategoryBullet | TankGamePhysicsCategoryMine;
	}
	return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
		@"aimingAt": _aimingAt.rep,
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"aimingAt", ^(id o) { self.aimingAt = [[Vector2 alloc] initWithRep:o]; });
}

- (float)turretRotation
{
	return [[[[BNZLine alloc] initAt:self.position to:_aimingAt] vector] angle] - self.rotation - M_PI_2;
}

- (void)fireBulletIntoLevel:(TankLevel*)level
{
	TankBullet *bullet = [TankBullet new];
	bullet.speed = TankBulletStandardSpeed;
	bullet.collisionTTL = 2;
	bullet.rotation = self.turretRotation + self.rotation;
    Vector2 *offset = [[Vector2 vectorWithX:0 y:TankCollisionRadius*1.5] vectorByRotatingByRadians:bullet.rotation];
	bullet.position = [self.position vectorByAddingVector:offset];
    [bullet updatePhysicsFromProperties];
	[[level mutableArrayValueForKey:@"bullets"] addObject:bullet];
}

- (void)layMineIntoLevel:(TankLevel *)level
{
    TankMine *mine = [TankMine new];
    Vector2 *offset = [[Vector2 vectorWithX:0 y:TankCollisionRadius*2.1] vectorByRotatingByRadians:self.rotation+M_PI];
	mine.position = [self.position vectorByAddingVector:offset];

    [mine updatePhysicsFromProperties];
    
    [[level mutableArrayValueForKey:@"mines"] addObject:mine];
}

-(void)applyForces
{
    if(![self.moveIntent length]) {
        self.physicsBody.velocity = CGPointZero;
        self.physicsBody.angularVelocity = 0;
        return [super applyForces];
    }

    if(!self.canMove) {
        // Rotate towards the intended direction
        Vector2 *look = [[Vector2 vectorWithX:0 y:1] vectorByRotatingByRadians:self.rotation];
        
        // Goals are relative to look dir!
        
        // Angle to move intent, from up
        float goal1 = [look angleTo:self.moveIntent];
        
        // Angle to inversed move intent, from up
        float goal2 = [look angleTo:[self.moveIntent invertedVector]];
        
        float goal = fabsf(goal1) < fabsf(goal2) ? goal1 : goal2;
        
        self.physicsBody.velocity = CGPointZero;
        self.physicsBody.angularVelocity = TankRotationSpeed * (goal < 0 ? -1 : 1);
        
        if(goal > -0.1 && goal < 0.1) {
            // Should snap rotation to correct angle... but that's not good for the
            // physics engine...
            self.physicsBody.rotation += goal;
            self.physicsBody.angularVelocity = 0;
            self.canMove = YES;
        }
    }
    
    if(self.canMove) {
        self.physicsBody.velocity = [[[self moveIntent] vectorByMultiplyingWithScalar:self.speed] point];
    }
}

- (void)collided:(SKPhysicsContact*)contact withBody:(SKPhysicsBody*)body entity:(WorldEntity*)other inGame:(TankGame*)game
{
    if(body.categoryBitMask & (TankGamePhysicsCategoryBullet | TankGamePhysicsCategoryMine)) {
        // This would be a good time for 'removeFromParent' to work when you're in multiple relationships...
        [[[game currentLevel] mutableArrayValueForKey:@"tanks"] removeObject:self];
        [[game mutableArrayValueForKey:@"enemyTanks"] removeObject:self];
        for(TankPlayer *player in game.players) {
            if(player.tank == self)
                player.tank = nil;
        }
    }
}

@end
