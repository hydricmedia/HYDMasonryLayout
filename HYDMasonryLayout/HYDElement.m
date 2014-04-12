//
//  HYDElement.m
//  HYDGridLayout
//
//  Created by Simon Hall on 21/03/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import "HYDElement.h"

@implementation HYDElement

- (id)initWithElementNo:(NSUInteger)elementNo
{
    self = [super init];
    if (self) {
        _elementNo = elementNo;
    }
    
    return self;
}

- (id)initWithLineArray:(NSArray *)array
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    NSString *rawElementNo = [array[0] stringByTrimmingCharactersInSet:charSet];

    self = [self initWithElementNo:[rawElementNo intValue]];
    
    if (self) {
        _elementWeight = [[array[1] stringByTrimmingCharactersInSet:charSet] floatValue];
        _elementName = [array[2] stringByTrimmingCharactersInSet:charSet];
        _elementSymbol = [array[3] stringByTrimmingCharactersInSet:charSet];
        _elementWidth = [self itemWidth];
        _elementHeight = [self itemHeight];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d -- %@: %@", self.elementNo, self.elementSymbol, self.elementName];
}

- (NSString *)descriptionWithWidthAndHeight {
    return [NSString stringWithFormat:@"%d -- %@: %@, Width: %f, Height: %f", self.elementNo, self.elementSymbol, self.elementName, self.elementWidth, self.elementHeight];
}

#pragma mark - Public methods

- (CGFloat)itemWidth {
    
    NSUInteger xRand = 0;
    while (xRand < 10) {
        xRand = arc4random() % 786;
    }
    
    return (CGFloat)xRand;
}

- (CGFloat)itemHeight {
    
    NSUInteger yRand = 0;
    while (yRand < 10) {
        yRand = arc4random() % 300;
    }
    
    return (CGFloat)yRand;
}

@end
