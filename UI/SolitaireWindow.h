//
//  SolitaireWindow.h
//  SmallSolitaire
//
//  Main window containing the solitaire game view.
//

#import <AppKit/AppKit.h>

@class SolitaireView;

@interface SolitaireWindow : NSWindow
{
    SolitaireView *_gameView;
}

- (void)newGame;

@end
