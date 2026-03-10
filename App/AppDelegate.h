//
//  AppDelegate.h
//  SmallSolitaire
//
//  App lifecycle and menu; creates the main game window.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif
#import "SSAppDelegate.h"

@class SolitaireWindow;

@interface AppDelegate : NSObject <SSAppDelegate>
{
    SolitaireWindow *_mainWindow;
}
- (void)buildMenu;
@end
