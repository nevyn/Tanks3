//
//  MVAppDelegate.h
//  MacTanks3
//

//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>

@interface MVAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SKView *skView;

@end


@interface TankSKView : SKView
@end