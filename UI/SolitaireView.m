//
//  SolitaireView.m
//  SmallSolitaire
//
//  Klondike solitaire: 7 tableau columns, 4 foundations, stock and waste.
//  Draw one card from stock; drag/drop and double-click to foundation.
//

#import "SolitaireView.h"
#import <stdlib.h>
#import <string.h>
#import <time.h>

#define SUIT(c)  ((c) / 13)
#define RANK(c)  ((c) % 13)
#define IS_RED(c) (SUIT(c) == 1 || SUIT(c) == 2)
#define RANK_VALUE(r) ((r) + 1)

static const CGFloat kCardWidth = 72.0;
static const CGFloat kCardHeight = 96.0;
static const CGFloat kCardSpacingX = 8.0;
static const CGFloat kCardSpacingY = 20.0;
static const CGFloat kMargin = 12.0;

typedef enum {
    PileNone = 0,
    PileStock,
    PileWaste,
    PileTableau0, PileTableau1, PileTableau2, PileTableau3, PileTableau4, PileTableau5, PileTableau6,
    PileFoundation0, PileFoundation1, PileFoundation2, PileFoundation3
} PileType;

static int PileTableauIndex(PileType p) {
    if (p >= PileTableau0 && p <= PileTableau6) return (int)(p - PileTableau0);
    return -1;
}
static int PileFoundationIndex(PileType p) {
    if (p >= PileFoundation0 && p <= PileFoundation3) return (int)(p - PileFoundation0);
    return -1;
}

@interface SolitaireView ()
@property (nonatomic, retain) NSMutableArray *stock;
@property (nonatomic, retain) NSMutableArray *waste;
@property (nonatomic, assign) NSInteger dragSourceIndex;
@property (nonatomic, assign) NSInteger dragSourceCount;
@property (nonatomic, assign) NSPoint dragStartPoint;
@property (nonatomic, assign) BOOL isDragging;
@end

@implementation SolitaireView
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize stock = _stock;
@synthesize waste = _waste;
@synthesize dragSourceIndex = _dragSourceIndex;
@synthesize dragSourceCount = _dragSourceCount;
@synthesize dragStartPoint = _dragStartPoint;
@synthesize isDragging = _isDragging;
#endif

+ (CGFloat)cardWidth { return kCardWidth; }
+ (CGFloat)cardHeight { return kCardHeight; }
+ (CGFloat)cardSpacingX { return kCardSpacingX; }
+ (CGFloat)cardSpacingY { return kCardSpacingY; }

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _stock = [[NSMutableArray alloc] init];
        _waste = [[NSMutableArray alloc] init];
        for (int i = 0; i < 7; i++) {
            _tableau[i] = [[NSMutableArray alloc] init];
            _tableauFaceDown[i] = 0;
        }
        for (int i = 0; i < 4; i++)
            _foundation[i] = [[NSMutableArray alloc] init];
        _dragSourcePile = (NSInteger)PileNone;
        _dragSourceIndex = 0;
        _dragSourceCount = 0;
        _isDragging = NO;
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_stock release];
    [_waste release];
    for (int i = 0; i < 7; i++) [_tableau[i] release];
    for (int i = 0; i < 4; i++) [_foundation[i] release];
    [super dealloc];
}
#endif

- (void)newGame {
    [_stock removeAllObjects];
    [_waste removeAllObjects];
    for (int i = 0; i < 7; i++) {
        [_tableau[i] removeAllObjects];
        _tableauFaceDown[i] = 0;
    }
    for (int i = 0; i < 4; i++)
        [_foundation[i] removeAllObjects];

    int deck[52];
    for (int i = 0; i < 52; i++) deck[i] = i;
    static BOOL seeded = NO;
    if (!seeded) { srandom((unsigned)time(NULL)); seeded = YES; }
    for (int i = 51; i > 0; i--) {
        int j = (int)(random() % (i + 1));
        int t = deck[i]; deck[i] = deck[j]; deck[j] = t;
    }

    int idx = 0;
    for (int col = 0; col < 7; col++) {
        for (int row = 0; row <= col; row++) {
            NSNumber *n = [NSNumber numberWithInt:deck[idx++]];
            [_tableau[col] addObject:n];
        }
        _tableauFaceDown[col] = col;
    }
    while (idx < 52) {
        [_stock addObject:[NSNumber numberWithInt:deck[idx++]]];
    }
    _dragSourcePile = (NSInteger)PileNone;
    _isDragging = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)isCardFaceUpInTableauColumn:(NSInteger)col index:(NSInteger)idx {
    return idx >= _tableauFaceDown[col];
}

- (int)cardAtTableauColumn:(NSInteger)col index:(NSInteger)idx {
    NSArray *arr = _tableau[col];
    if (idx < 0 || idx >= (NSInteger)[arr count]) return -1;
    return [[arr objectAtIndex:idx] intValue];
}

- (int)topCardOfWaste {
    if ([_waste count] == 0) return -1;
    return [[_waste lastObject] intValue];
}

- (int)topCardOfFoundation:(NSInteger)f {
    NSArray *arr = _foundation[f];
    if ([arr count] == 0) return -1;
    return [[arr lastObject] intValue];
}

- (void)drawOneFromStock {
    if ([_stock count] > 0) {
        NSNumber *n = [_stock lastObject];
        [_stock removeLastObject];
        [_waste addObject:n];
        [self setNeedsDisplay:YES];
    } else if ([_waste count] > 0) {
        while ([_waste count] > 0) {
            NSNumber *n = [_waste lastObject];
            [_waste removeLastObject];
            [_stock addObject:n];
        }
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)canPlaceCard:(int)card onFoundation:(NSInteger)found {
    int top = [self topCardOfFoundation:found];
    int rank = RANK(card);
    int suit = SUIT(card);
    if (top < 0) return (rank == 0);
    return SUIT(top) == suit && RANK(top) == rank - 1;
}

- (BOOL)canPlaceCard:(int)card onTableauColumn:(NSInteger)col {
    NSArray *arr = _tableau[col];
    if ([arr count] == 0) return (RANK(card) == 12);
    int top = [[arr lastObject] intValue];
    return IS_RED(card) != IS_RED(top) && RANK(top) == RANK(card) + 1;
}

- (BOOL)canPlaceSequenceFromColumn:(NSInteger)col fromIndex:(NSInteger)fromIdx onTableauColumn:(NSInteger)targetCol {
    NSArray *src = _tableau[col];
    if (fromIdx >= (NSInteger)[src count]) return NO;
    int firstCard = [[src objectAtIndex:fromIdx] intValue];
    if (![self isCardFaceUpInTableauColumn:col index:fromIdx]) return NO;
    return [self canPlaceCard:firstCard onTableauColumn:targetCol];
}

- (void)moveWasteToFoundation {
    if ([_waste count] == 0) return;
    int card = [self topCardOfWaste];
    for (int f = 0; f < 4; f++) {
        if ([self canPlaceCard:card onFoundation:f]) {
            [_waste removeLastObject];
            [_foundation[f] addObject:[NSNumber numberWithInt:card]];
            [self setNeedsDisplay:YES];
            return;
        }
    }
}

- (void)moveTableauTopToFoundation:(NSInteger)col {
    NSMutableArray *arr = _tableau[col];
    if ([arr count] == 0) return;
    NSInteger idx = [arr count] - 1;
    if (![self isCardFaceUpInTableauColumn:col index:idx]) return;
    int card = [[arr lastObject] intValue];
    for (int f = 0; f < 4; f++) {
        if ([self canPlaceCard:card onFoundation:f]) {
            [arr removeLastObject];
            [_foundation[f] addObject:[NSNumber numberWithInt:card]];
            if (_tableauFaceDown[col] == [arr count] && [arr count] > 0)
                _tableauFaceDown[col]--;
            [self setNeedsDisplay:YES];
            return;
        }
    }
}

- (void)moveCardsFromTableauColumn:(NSInteger)srcCol fromIndex:(NSInteger)fromIdx toTableauColumn:(NSInteger)dstCol count:(NSInteger)count {
    NSMutableArray *src = _tableau[srcCol];
    NSMutableArray *dst = _tableau[dstCol];
    if (fromIdx < 0 || fromIdx + count > (NSInteger)[src count]) return;
    NSRange r = NSMakeRange((NSUInteger)fromIdx, (NSUInteger)count);
    NSArray *moving = [src subarrayWithRange:r];
    [src removeObjectsInRange:r];
    [dst addObjectsFromArray:moving];
    if (_tableauFaceDown[srcCol] >= (NSInteger)[src count] && [src count] > 0)
        _tableauFaceDown[srcCol] = (NSInteger)[src count] - 1;
    [self setNeedsDisplay:YES];
}

- (void)moveWasteToTableauColumn:(NSInteger)col {
    if ([_waste count] == 0) return;
    int card = [self topCardOfWaste];
    if (![self canPlaceCard:card onTableauColumn:col]) return;
    [_waste removeLastObject];
    [_tableau[col] addObject:[NSNumber numberWithInt:card]];
    [self setNeedsDisplay:YES];
}

- (void)moveTableauTopToTableauColumn:(NSInteger)srcCol toColumn:(NSInteger)dstCol {
    if (srcCol == dstCol) return;
    NSMutableArray *src = _tableau[srcCol];
    if ([src count] == 0) return;
    NSInteger idx = [src count] - 1;
    if (![self isCardFaceUpInTableauColumn:srcCol index:idx]) return;
    int card = [[src lastObject] intValue];
    if (![self canPlaceCard:card onTableauColumn:dstCol]) return;
    [src removeLastObject];
    [_tableau[dstCol] addObject:[NSNumber numberWithInt:card]];
    if (_tableauFaceDown[srcCol] == (NSInteger)[src count] && [src count] > 0)
        _tableauFaceDown[srcCol]--;
    [self setNeedsDisplay:YES];
}

- (BOOL)hasWon {
    for (int f = 0; f < 4; f++) {
        if ([_foundation[f] count] != 13) return NO;
    }
    return YES;
}

#pragma mark - Layout and hit test

- (NSRect)boundsForStock {
    return NSMakeRect(kMargin, NSMaxY([self bounds]) - kMargin - kCardHeight, kCardWidth, kCardHeight);
}

- (NSRect)boundsForWaste {
    return NSMakeRect(kMargin + kCardWidth + kCardSpacingX, NSMaxY([self bounds]) - kMargin - kCardHeight, kCardWidth, kCardHeight);
}

- (NSRect)boundsForTableauColumn:(NSInteger)col {
    CGFloat x = kMargin + (kCardWidth + kCardSpacingX) * (CGFloat)(col + 2);
    return NSMakeRect(x, kMargin, kCardWidth, NSHeight([self bounds]) - 2 * kMargin);
}

- (NSRect)boundsForFoundation:(NSInteger)f {
    CGFloat x = kMargin + (kCardWidth + kCardSpacingX) * (3 + f);
    return NSMakeRect(x, NSMaxY([self bounds]) - kMargin - kCardHeight, kCardWidth, kCardHeight);
}

- (void)getPileAtPoint:(NSPoint)point pile:(PileType *)outPile index:(NSInteger *)outIndex {
    NSRect b = [self bounds];
    CGFloat maxY = NSMaxY(b);
    *outPile = PileNone;
    *outIndex = 0;

    if (NSPointInRect(point, [self boundsForStock])) {
        *outPile = PileStock;
        return;
    }
    if (NSPointInRect(point, [self boundsForWaste])) {
        *outPile = PileWaste;
        *outIndex = [_waste count] > 0 ? (NSInteger)[_waste count] - 1 : 0;
        return;
    }
    for (int f = 0; f < 4; f++) {
        if (NSPointInRect(point, [self boundsForFoundation:f])) {
            *outPile = (PileType)(PileFoundation0 + f);
            *outIndex = [_foundation[f] count] > 0 ? (NSInteger)[_foundation[f] count] - 1 : 0;
            return;
        }
    }
    for (int c = 0; c < 7; c++) {
        NSRect colRect = [self boundsForTableauColumn:c];
        if (point.x < NSMinX(colRect) || point.x > NSMaxX(colRect)) continue;
        NSArray *arr = _tableau[c];
        NSInteger n = (NSInteger)[arr count];
        if (n == 0) {
            if (point.y >= maxY - kMargin - kCardHeight && point.y <= maxY - kMargin) {
                *outPile = (PileType)(PileTableau0 + c);
                *outIndex = 0;
            }
            return;
        }
        CGFloat y = maxY - kMargin - kCardHeight;
        for (NSInteger i = 0; i < n; i++) {
            if (i > 0)
                y -= (i <= _tableauFaceDown[c]) ? (kCardHeight * 0.2) : kCardSpacingY;
            if (point.y >= y - 4 && point.y <= y + kCardHeight + 4) {
                *outPile = (PileType)(PileTableau0 + c);
                *outIndex = i;
                return;
            }
        }
    }
}

- (NSInteger)tableauColumnIndexAtPoint:(NSPoint)point {
    for (int c = 0; c < 7; c++) {
        if (NSPointInRect(point, [self boundsForTableauColumn:c]))
            return c;
    }
    return -1;
}

- (NSInteger)foundationIndexAtPoint:(NSPoint)point {
    for (int f = 0; f < 4; f++) {
        if (NSPointInRect(point, [self boundsForFoundation:f]))
            return f;
    }
    return -1;
}

#pragma mark - Drawing

- (NSString *)rankString:(int)rank {
    static NSString *ranks[] = { @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K" };
    if (rank < 0 || rank > 12) return @"";
    return ranks[rank];
}

- (NSString *)suitString:(int)suit {
    static NSString *suits[] = { @"♠", @"♥", @"♦", @"♣" };
    if (suit < 0 || suit > 3) return @"";
    return suits[suit];
}

- (void)drawCard:(int)card atPoint:(NSPoint)pt faceUp:(BOOL)faceUp {
    NSRect rect = NSMakeRect(pt.x, pt.y, kCardWidth, kCardHeight);
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
    [[NSColor blackColor] setStroke];
    NSFrameRect(rect);
    if (!faceUp) {
        [[NSColor colorWithCalibratedRed:0.2 green:0.3 blue:0.6 alpha:1.0] setFill];
        NSRectFill(NSInsetRect(rect, 4, 4));
        return;
    }
    NSString *rankStr = [self rankString:RANK(card)];
    NSString *suitStr = [self suitString:SUIT(card)];
    BOOL red = IS_RED(card);
    NSColor *textColor = red ? [NSColor redColor] : [NSColor blackColor];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont systemFontOfSize:14], NSFontAttributeName,
        textColor, NSForegroundColorAttributeName, nil];
    [rankStr drawAtPoint:NSMakePoint(pt.x + 4, pt.y + kCardHeight - 20) withAttributes:attrs];
    [suitStr drawAtPoint:NSMakePoint(pt.x + 4, pt.y + kCardHeight - 38) withAttributes:attrs];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect b = [self bounds];
    [[NSColor colorWithCalibratedRed:0.2 green:0.5 blue:0.2 alpha:1.0] setFill];
    NSRectFill(b);

    CGFloat maxY = NSMaxY(b);

    [self drawCard:-1 atPoint:NSMakePoint(kMargin, maxY - kMargin - kCardHeight) faceUp:NO];
    if ([_stock count] > 0) {
        NSPoint pt = NSMakePoint(kMargin, maxY - kMargin - kCardHeight);
        [self drawCard:[[_stock lastObject] intValue] atPoint:pt faceUp:NO];
    }

    if ([_waste count] > 0) {
        NSPoint pt = NSMakePoint(kMargin + kCardWidth + kCardSpacingX, maxY - kMargin - kCardHeight);
        [self drawCard:[self topCardOfWaste] atPoint:pt faceUp:YES];
    }

    for (int f = 0; f < 4; f++) {
        NSPoint pt = NSMakePoint(kMargin + (kCardWidth + kCardSpacingX) * (3 + f), maxY - kMargin - kCardHeight);
        if ([_foundation[f] count] > 0)
            [self drawCard:[self topCardOfFoundation:f] atPoint:pt faceUp:YES];
        else {
            [[NSColor colorWithCalibratedWhite:0.9 alpha:0.5] setStroke];
            NSFrameRect(NSMakeRect(pt.x, pt.y, kCardWidth, kCardHeight));
        }
    }

    for (int c = 0; c < 7; c++) {
        NSArray *arr = _tableau[c];
        CGFloat x = kMargin + (kCardWidth + kCardSpacingX) * (CGFloat)(c + 2);
        CGFloat y = maxY - kMargin - kCardHeight;
        for (NSInteger i = 0; i < (NSInteger)[arr count]; i++) {
            BOOL faceUp = [self isCardFaceUpInTableauColumn:c index:i];
            int card = [[arr objectAtIndex:i] intValue];
            [self drawCard:card atPoint:NSMakePoint(x, y) faceUp:faceUp];
            y -= (i < _tableauFaceDown[c]) ? kCardHeight * 0.2 : kCardSpacingY;
        }
    }
}

#pragma mark - Mouse

- (void)mouseDown:(NSEvent *)event {
    NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
    _dragStartPoint = loc;
    PileType pile = PileNone;
    NSInteger idx = 0;
    [self getPileAtPoint:loc pile:&pile index:&idx];

    if ([event clickCount] == 2) {
        if (pile == PileWaste)
            [self moveWasteToFoundation];
        else if (pile >= PileTableau0 && pile <= PileTableau6)
            [self moveTableauTopToFoundation:PileTableauIndex(pile)];
        if ([self hasWon])
            [[self window] setTitle:@"SmallSolitaire — You won!"];
        return;
    }

    if (pile == PileStock) {
        [self drawOneFromStock];
        return;
    }

    _dragSourcePile = (NSInteger)pile;
    _dragSourceIndex = idx;
    _dragSourceCount = 1;
    if (pile >= PileTableau0 && pile <= PileTableau6) {
        NSArray *arr = _tableau[PileTableauIndex(pile)];
        _dragSourceCount = (NSInteger)[arr count] - idx;
    }
    _isDragging = YES;
}

- (void)mouseUp:(NSEvent *)event {
    if (!_isDragging) return;
    NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat dx = loc.x - _dragStartPoint.x, dy = loc.y - _dragStartPoint.y;
    if (dx*dx + dy*dy < 25) {
        _isDragging = NO;
        _dragSourcePile = (NSInteger)PileNone;
        return;
    }

    NSInteger dstCol = [self tableauColumnIndexAtPoint:loc];
    NSInteger dstFound = [self foundationIndexAtPoint:loc];

    if (_dragSourcePile == PileWaste && [_waste count] > 0) {
        int card = [self topCardOfWaste];
        if (dstFound >= 0 && [self canPlaceCard:card onFoundation:(NSUInteger)dstFound]) {
            [_waste removeLastObject];
            [_foundation[dstFound] addObject:[NSNumber numberWithInt:card]];
        } else if (dstCol >= 0 && [self canPlaceCard:card onTableauColumn:dstCol]) {
            [_waste removeLastObject];
            [_tableau[dstCol] addObject:[NSNumber numberWithInt:card]];
        }
    } else if (_dragSourcePile >= PileTableau0 && _dragSourcePile <= PileTableau6) {
        NSInteger srcCol = PileTableauIndex((PileType)_dragSourcePile);
        NSArray *src = _tableau[srcCol];
        if (_dragSourceIndex >= (NSInteger)[src count]) { _isDragging = NO; _dragSourcePile = PileNone; return; }
        int card = [[src objectAtIndex:_dragSourceIndex] intValue];
        if (dstFound >= 0 && _dragSourceIndex == (NSInteger)[src count] - 1 && [self canPlaceCard:card onFoundation:(NSUInteger)dstFound]) {
            [_tableau[srcCol] removeLastObject];
            [_foundation[dstFound] addObject:[NSNumber numberWithInt:card]];
            if (_tableauFaceDown[srcCol] == (NSInteger)[_tableau[srcCol] count] && [_tableau[srcCol] count] > 0)
                _tableauFaceDown[srcCol]--;
        } else if (dstCol >= 0 && dstCol != srcCol && [self canPlaceCard:card onTableauColumn:dstCol]) {
            [self moveCardsFromTableauColumn:srcCol fromIndex:_dragSourceIndex toTableauColumn:dstCol count:_dragSourceCount];
        }
    } else if (_dragSourcePile >= PileFoundation0 && _dragSourcePile <= PileFoundation3 && dstCol >= 0) {
        NSInteger srcF = PileFoundationIndex((PileType)_dragSourcePile);
        if ([_foundation[srcF] count] == 0) { _isDragging = NO; _dragSourcePile = PileNone; return; }
        int card = [self topCardOfFoundation:srcF];
        if ([self canPlaceCard:card onTableauColumn:dstCol]) {
            [_foundation[srcF] removeLastObject];
            [_tableau[dstCol] addObject:[NSNumber numberWithInt:card]];
        }
    }

    _isDragging = NO;
    _dragSourcePile = (NSInteger)PileNone;
    [self setNeedsDisplay:YES];
    if ([self hasWon])
        [[self window] setTitle:@"SmallSolitaire — You won!"];
}

@end
