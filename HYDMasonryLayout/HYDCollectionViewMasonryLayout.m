//
//  HYDCollectionViewMasonryLayout.m
//  HYDMasonryLayout
//
//  Created by Simon Hall on 12/04/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import "HYDCollectionViewMasonryLayout.h"

@interface HYDCollectionViewMasonryLayout ()

@property (nonatomic, strong) NSMutableDictionary *layoutInfo;

@end

@implementation HYDCollectionViewMasonryLayout

#pragma mark - Lifecycle
- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
}

#pragma mark - Accessors

- (NSMutableDictionary *)layoutInfo {
    
    if (!_layoutInfo) {
        _layoutInfo = [NSMutableDictionary new];
    }
    
    return _layoutInfo;
}

#pragma mark - Layout

- (void)prepareLayout {

    self.layoutInfo = nil;
    
    NSIndexPath *indexPath;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger item = 0; item < itemCount; item++) {
        
        indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGSize size = [self sizeForItemAtIndexPath:indexPath];
        CGPoint origin = [self originForItemAtIndexPath:indexPath];
        
        attributes.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        
        self.layoutInfo[indexPath] = attributes;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *attributesArray = [NSMutableArray new];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [attributesArray addObject:self.layoutInfo[indexPath]];
        }
    }];
    
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.layoutInfo[indexPath];
}

- (CGSize)collectionViewContentSize {
    
    return CGSizeZero;
}

#pragma mark - Helpers

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        size  = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    }
    
    return size;
}

- (CGPoint)originForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGPointZero;
}

@end
