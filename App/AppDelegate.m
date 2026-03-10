//
//  AppDelegate.m
//  SmallSolitaire
//

#import "AppDelegate.h"
#import "SolitaireWindow.h"
#import "SSAppDelegate.h"
#import "SSHostApplication.h"
#import "SSMainMenu.h"
#import "SSAboutPanel.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching {
    [self buildMenu];
}

- (void)applicationDidFinishLaunching {
    _mainWindow = [[SolitaireWindow alloc] init];
    [_mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
#if !TARGET_OS_IPHONE
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallSolitaire"];
    [menu setAboutAppName:@"SmallSolitaire"];
    [menu setAboutVersion:@"1.0"];
    [menu setAboutTarget:self];
    NSArray *items = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"New Game" action:@selector(newGame:) keyEquivalent:@"n" modifierMask:NSCommandKeyMask target:self],
        nil];
    [menu buildMenuWithItems:items quitTitle:@"Quit SmallSolitaire" quitKeyEquivalent:@"q"];
    [menu install];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
#endif
}

- (void)newGame:(id)sender {
    (void)sender;
    [_mainWindow newGame];
}

- (void)showAbout:(id)sender {
    (void)sender;
    [SSAboutPanel showWithAppName:@"SmallSolitaire" version:@"1.0"];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mainWindow release];
    [super dealloc];
}
#endif

@end
