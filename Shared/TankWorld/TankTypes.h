static const int kTankServerPort = 29534;

typedef enum {
    TankGamePhysicsCategoryBullet = 1 << 1,
    TankGamePhysicsCategoryWall = 1 << 2,
    TankGamePhysicsCategoryDestructableWall = 1 << 3,
    TankGamePhysicsCategoryTank = 1 << 4,
    TankGamePhysicsCategoryMine = 1 << 5,
    
    TankGamePhysicsCategoryMakesBulletBounce = 1 << 10,
    TankGamePhysicsCategoryMakesBulletExplode = 1 << 11,
} TankGamePhysicsCategory;