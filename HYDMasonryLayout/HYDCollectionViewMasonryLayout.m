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
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, strong) NSMutableArray *columnHeights;
@property (nonatomic, assign) CGFloat columnWidth;

@end

@implementation HYDCollectionViewMasonryLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    HYDCollectionViewMasonryLayoutAttributes *newAttributes = [super copyWithZone:zone];

    newAttributes.columnIndex = _columnIndex;
    newAttributes.columnSpan = _columnSpan;
    
    return newAttributes;
}

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

- (void)dealloc
{
    [_columnHeights removeAllObjects];
    _columnHeights = nil;
    
    _layoutInfo = nil;
}

#pragma mark - Layout

- (void)prepareLayout {
    
    NSAssert(self.delegate != nil, @"Column Flow delegate cannot be nil");

    [super prepareLayout];
    
    self.layoutInfo = nil;
    
    [self configureSectionInsetsForSectionAtIndex:0]; //Currently only one section
    [self configureMinInteritemSpacingForSectionAtIndex:0];
    [self configureMinLineSpacingForSectionAtIndex:0];
    [self configureColumnsForSectionAtIndex:0];
    
    for (NSUInteger i=0; i < self.numberOfColumns; i++) {
        self.columnHeights[i] = @(self.sectionInset.top); // plus header height
    }
    
    NSIndexPath *indexPath;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger item = 0; item < itemCount; item++) {
        
        indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        HYDCollectionViewMasonryLayoutAttributes *attributes = [HYDCollectionViewMasonryLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        attributes.size = [self sizeForItemAtIndexPath:indexPath];
        attributes.columnSpan = [self columnSpanForItemWithAttributes:attributes];
        CGPoint origin = [self originForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes];
        
        attributes.frame = CGRectMake(origin.x, origin.y, attributes.size.width, attributes.size.height);
        
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
    
    __block CGFloat height = 0;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber *columnHeight, NSUInteger idx, BOOL *stop) {
        height = MAX([columnHeight floatValue], height);
    }];
    
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height + self.sectionInset.bottom);
}

#pragma mark - Accessors

- (NSMutableDictionary *)layoutInfo {
    
    if (!_layoutInfo) {
        _layoutInfo = [NSMutableDictionary new];
    }
    
    return _layoutInfo;
}

- (NSMutableArray *)columnHeights {
    
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray arrayWithCapacity:_numberOfColumns];
    }
    
    return _columnHeights;
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns {
    
    if (_numberOfColumns != numberOfColumns && numberOfColumns != 0) {
        _numberOfColumns = numberOfColumns;
        [self configureColumnWidth];
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    
    if (_minimumLineSpacing != minimumLineSpacing) {
        _minimumLineSpacing = minimumLineSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    
    if (!_minimumInteritemSpacing != minimumInteritemSpacing) {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

#pragma mark - Helpers

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        size  = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    }
    
    return size;
}

- (CGPoint)originForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    
    attributes.columnIndex = 0;
    CGPoint origin = CGPointMake(self.sectionInset.left, self.sectionInset.top);
    
    if (attributes.indexPath.item != 0) {
        attributes.columnIndex = [self columnIndexForItemWithAttributes:attributes];
        origin.x = [self xOriginForItemWithAttribites:attributes] + origin.x;
        origin.y = [self yOriginForItemWithAttributes:attributes] + origin.y;
    }
    
    // Update Column heights array
    
    for (NSUInteger i=attributes.columnIndex; i < attributes.columnIndex + attributes.columnSpan; i++) {
        self.columnHeights[i] = @(origin.y + attributes.size.height);
    }
    
    return origin;
}

- (NSUInteger)columnIndexForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
        
    //Calculate the columnIndex based on the shortest column that will take the item span
    
    NSUInteger columnIndex = 0;
    if (attributes.indexPath.item != 0) {
        CGFloat columnHeight = MAXFLOAT;
        for (NSUInteger i = 0; i <= self.numberOfColumns - attributes.columnSpan; i++) {
            if ([self.columnHeights[i] floatValue] < columnHeight) {
                columnHeight = [self.columnHeights[i] floatValue];
                columnIndex = i;
            }
        }
    }
    
    return columnIndex;
}

- (CGFloat)xOriginForItemWithAttribites:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    return (self.columnWidth * attributes.columnIndex);
}

- (CGFloat)yOriginForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    
    __block CGFloat yPosition = 0;
    for (NSUInteger i=attributes.columnIndex; i<attributes.columnIndex + attributes.columnSpan; i++) {
        yPosition = MAX([self.columnHeights[i] floatValue], yPosition);
    }
    
    if ([self.columnHeights[attributes.columnIndex] integerValue] > 0) {
        yPosition = yPosition + self.minimumLineSpacing;
    }
    
    return yPosition;
}

- (NSUInteger)columnSpanForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    
    NSUInteger columnSpan = 1;
    CGFloat totalColumnWidth = 0;
    
    for (NSUInteger i=0; i < self.numberOfColumns; i++) {
        totalColumnWidth += self.columnWidth;
        if (attributes.size.width > totalColumnWidth) {
            columnSpan++;
        }
    }
    
    return columnSpan;
}

- (void)configureColumnWidth {
    
    //interitemSpacing
    
    self.columnWidth = floor((CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.left - self.sectionInset.right) / self.numberOfColumns);
}

- (void)configureSectionInsetsForSectionAtIndex:(NSUInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        _sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
}

- (void)configureMinLineSpacingForSectionAtIndex:(NSUInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        _minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:0];
    }
}

- (void)configureMinInteritemSpacingForSectionAtIndex:(NSUInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        _minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
}

- (void)configureColumnsForSectionAtIndex:(NSUInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(numberOfColumnsInCollectionView:)]) {
        _numberOfColumns = [self.delegate numberOfColumnsInCollectionView:self.collectionView];
        _numberOfColumns = (_numberOfColumns == 0) ? 1: _numberOfColumns;
        [self configureColumnWidth];
    }
}

@end
