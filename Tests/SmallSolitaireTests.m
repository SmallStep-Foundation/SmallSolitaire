//
//  SmallSolitaireTests.m
//  SmallSolitaire unit tests
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SSTestMacros.h"
#import "../App/AppDelegate.h"
#import "../UI/SolitaireView.h"

static void testAppDelegateMenuBuild(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    AppDelegate *delegate = [[AppDelegate alloc] init];
    [delegate buildMenu];
    SS_TEST_ASSERT(YES, "AppDelegate buildMenu did not crash");
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [delegate release];
#endif
    RELEASE(pool);
}

static void testSolitaireViewCardHelpers(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    SolitaireView *view = [[SolitaireView alloc] initWithFrame:NSMakeRect(0, 0, 500, 400)];
    [view newGame];
    SS_TEST_ASSERT(view != nil, "SolitaireView init and newGame");
    NSString *rank0 = [view rankString:0];
    NSString *rank12 = [view rankString:12];
    SS_TEST_ASSERT(rank0 != nil && [rank0 isEqualToString:@"A"], "rankString 0 = A");
    SS_TEST_ASSERT(rank12 != nil && [rank12 isEqualToString:@"K"], "rankString 12 = K");
    SS_TEST_ASSERT([view canPlaceCard:0 onFoundation:0], "Ace can place on empty foundation");
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [view release];
#endif
    RELEASE(pool);
}

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;
    CREATE_AUTORELEASE_POOL(pool);
    [NSApplication sharedApplication];

    testAppDelegateMenuBuild();
    testSolitaireViewCardHelpers();

    SS_TEST_SUMMARY();
    RELEASE(pool);
    return SS_TEST_RETURN();
}
