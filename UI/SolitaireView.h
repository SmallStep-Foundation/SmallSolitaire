//
//  SolitaireView.h
//  SmallSolitaire
//
//  Custom view that draws the Klondike solitaire layout and handles mouse input.
//

#import <AppKit/AppKit.h>

@interface SolitaireView : NSView
{
    NSMutableArray *_stock;
    NSMutableArray *_waste;
    NSMutableArray *_tableau[7];
    NSInteger _tableauFaceDown[7];
    NSMutableArray *_foundation[4];
    NSInteger _dragSourcePile;
    NSInteger _dragSourceIndex;
    NSInteger _dragSourceCount;
    NSPoint _dragStartPoint;
    BOOL _isDragging;
}

+ (CGFloat)cardWidth;
+ (CGFloat)cardHeight;
+ (CGFloat)cardSpacingX;
+ (CGFloat)cardSpacingY;

- (void)newGame;

@end
