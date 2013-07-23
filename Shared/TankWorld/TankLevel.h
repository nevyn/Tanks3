#import <WorldKit/Shared/Shared.h>

@interface TankLevel : WorldEntity
@property(nonatomic,readonly) WORLD_ARRAY *bullets;
@property(nonatomic,readonly) WORLD_ARRAY *walls; // BNZLines
@property(nonatomic,WORLD_WRITABLE) CGSize levelSize;
@end
