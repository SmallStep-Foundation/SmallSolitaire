//
//  SolitaireWindow.m
//  SmallSolitaire
//

#import "SolitaireWindow.h"
#import "SolitaireView.h"
#import "SSWindowStyle.h"

static const CGFloat kMargin = 16.0;

@interface SolitaireWindow ()
@property (nonatomic, retain) SolitaireView *gameView;
@end

@implementation SolitaireWindow
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize gameView = _gameView;
#endif

- (instancetype)init {
    SolitaireView *view = [[SolitaireView alloc] initWithFrame:NSZeroRect];

    CGFloat cardW = [SolitaireView cardWidth];
    CGFloat cardH = [SolitaireView cardHeight];
    CGFloat contentW = 7 * (cardW + [SolitaireView cardSpacingX]) + cardW + 2 * kMargin;
    CGFloat contentH = cardH * 4 + 2 * kMargin;
    NSRect frame = NSMakeRect(100, 100, contentW, contentH);

    NSUInteger style = [SSWindowStyle standardWindowMask];
    self = [super initWithContentRect:frame
                             styleMask:style
                               backing:NSBackingStoreBuffered
                                 defer:NO];
    if (self) {
        [self setTitle:@"SmallSolitaire"];
        [self setReleasedWhenClosed:NO];
        _gameView = view;
        [view setFrame:[[self contentView] bounds]];
        [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [[self contentView] addSubview:view];
        [view newGame];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [view release];
#endif
    }
    return self;
}

- (void)newGame {
    [_gameView newGame];
    [self setTitle:@"SmallSolitaire"];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_gameView release];
    [super dealloc];
}
#endif

@end
