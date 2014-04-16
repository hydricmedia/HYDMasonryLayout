//
//  HYDElement.h
//  HYDGridLayout
//
//  Created by Simon Hall on 21/03/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYDElement : NSObject

@property (nonatomic, assign) NSUInteger elementNo;
@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSString *elementSymbol;
@property (nonatomic, assign) CGFloat elementWeight;

@property (nonatomic, assign) CGFloat elementWidth;
@property (nonatomic, assign) CGFloat elementHeight;
@property (nonatomic, assign) CGFloat elementWidthLandscape;

- (id)initWithLineArray:(NSArray *)array;
- (NSString *)descriptionWithWidthAndHeight;

@end
