//
//  HYDCollectionViewMasonryLayout.m
//  HYDMasonryLayout
//
//  Created by Simon Hall on 12/04/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import "HYDCollectionViewMasonryLayout.h"

static NSString *const HYDMasonryElementKindCell = @"HYDMasonryElementKindCell";

@interface HYDCollectionViewMasonryLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, strong) NSMutableArray *sectionHeights;
@property (nonatomic, strong) NSMutableDictionary *columnHeights;
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
    
    _numberOfColumns = 2;
    _minimumLineSpacing = 10.f;
    _minimumInteritemSpacing = 10.f;
    _sectionInset = UIEdgeInsetsZero;
    _headerReferenceSize = _footerReferenceSize = CGSizeZero;
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
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    UICollectionViewLayoutAttributes *headerLayoutAttributes;
    UICollectionViewLayoutAttributes *footerLayoutAttributes;
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *footerLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        [self headerSizeForSectionAtIndex:section];
        [self footerSizeForSectionAtIndex:section];
        [self configureSectionInsetsForSectionAtIndex:section];
        [self configureMinInteritemSpacingForSectionAtIndex:section];
        [self configureMinLineSpacingForSectionAtIndex:section];
        [self configureColumnsForSectionAtIndex:section];
        
        headerLayoutAttributes = nil;
        footerLayoutAttributes = nil;
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
        
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];

            // Layout the Header
            
            if (item == 0 && self.headerReferenceSize.height > 0.f) {
                headerLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
                headerLayoutAttributes.frame = CGRectMake(0.f, (section == 0) ? 0.f : [self sectionHeightForSection:section-1], self.headerReferenceSize.width, self.headerReferenceSize.height);
                headerLayoutInfo[indexPath] = headerLayoutAttributes;
            }
            
            // Layout the Items
            
            HYDCollectionViewMasonryLayoutAttributes *attributes = [HYDCollectionViewMasonryLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            attributes.size = [self sizeForItemAtIndexPath:indexPath];
            attributes.columnSpan = [self columnSpanForItemWithAttributes:attributes];
            CGPoint origin = [self originForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes];
            
            attributes.frame = CGRectMake(origin.x, origin.y, attributes.size.width, attributes.size.height);
            
            cellLayoutInfo[indexPath] = attributes;
            
            // Layout the Footer
            
            if (item == itemCount - 1) {
                
                self.sectionHeights[section] = @([self sectionHeightForSection:section]);
                
                if (self.footerReferenceSize.height > 0) {
                    footerLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
                    footerLayoutAttributes.frame = CGRectMake(0.f, [self sectionHeightForSection:section] - self.footerReferenceSize.height, self.footerReferenceSize.width, self.footerReferenceSize.height);
                    footerLayoutInfo[indexPath] = footerLayoutAttributes;
                }
            }
        }
        
        newLayoutInfo[HYDMasonryElementKindCell] = cellLayoutInfo;
        if (headerLayoutAttributes) newLayoutInfo[UICollectionElementKindSectionHeader] = headerLayoutInfo;
        if (footerLayoutAttributes) newLayoutInfo[UICollectionElementKindSectionFooter] = footerLayoutInfo;
    }

    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *attributesArray = [NSMutableArray new];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementType, NSDictionary *elementsInfo, BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }];
    }];
    
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[HYDMasonryElementKindCell][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[kind][indexPath];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), [[self.sectionHeights lastObject] floatValue]);
}

- (CGFloat)sectionHeightForSection:(NSUInteger)section {

    __block CGFloat height = 0;
    
    NSArray *sectionHeights = self.columnHeights[@(section)];
    
    [sectionHeights enumerateObjectsUsingBlock:^(NSNumber *columnHeight, NSUInteger idx, BOOL *stop) {
        height = MAX([columnHeight floatValue], height);
    }];
    
    return height + self.sectionInset.bottom + self.footerReferenceSize.height;
}

#pragma mark - Accessors

- (NSMutableArray *)sectionHeights {
    
    if (!_sectionHeights) {
        _sectionHeights = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfSections]];
    }
    
    return _sectionHeights;
}

- (NSMutableDictionary *)columnHeights {
    
    if (!_columnHeights) {
        _columnHeights = [NSMutableDictionary dictionaryWithCapacity:[self.collectionView numberOfSections]];
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
    CGPoint origin = CGPointZero;
    
    attributes.columnIndex = [self columnIndexForItemWithAttributes:attributes];
    origin.x = [self xOriginForItemWithAttribites:attributes];
    origin.y = [self yOriginForItemWithAttributes:attributes];
    
    // Update Column heights array
    
    NSMutableArray *sectionColumnHeights = (NSMutableArray *)self.columnHeights[@(attributes.indexPath.section)];
    for (NSUInteger i=attributes.columnIndex; i < attributes.columnIndex + attributes.columnSpan; i++) {
        sectionColumnHeights[i] = @(origin.y + attributes.size.height);
    }
    
    return origin;
}

- (NSUInteger)columnIndexForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
        
    //Calculate the columnIndex based on the shortest column that will take the item span
    
    NSUInteger columnIndex = 0;
    NSArray *sectionColumnHeights = (NSArray *)self.columnHeights[@(attributes.indexPath.section)];
    
    if (attributes.indexPath.item != 0) {
        CGFloat columnHeight = MAXFLOAT;
        for (NSUInteger i = 0; i <= self.numberOfColumns - attributes.columnSpan; i++) {
            if ([sectionColumnHeights[i] floatValue] < columnHeight) {
                columnHeight = [sectionColumnHeights[i] floatValue];
                columnIndex = i;
            }
        }
    }
    
    return columnIndex;
}

- (CGFloat)xOriginForItemWithAttribites:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    return (((self.columnWidth + self.minimumInteritemSpacing) * attributes.columnIndex) + self.sectionInset.left);
}

- (CGFloat)yOriginForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    
    __block CGFloat yPosition = 0;
    NSArray *sectionColumnHeights = (NSArray *)self.columnHeights[@(attributes.indexPath.section)];
    for (NSUInteger i=attributes.columnIndex; i<attributes.columnIndex + attributes.columnSpan; i++) {
        yPosition = MAX([sectionColumnHeights[i] floatValue], yPosition);
    }
    
    if (attributes.indexPath.section > 0 && [sectionColumnHeights[attributes.columnIndex] integerValue] <= (self.sectionInset.top + self.headerReferenceSize.height)) {
        yPosition = yPosition + [self sectionHeightForSection:attributes.indexPath.section - 1];
    }
    
    if ([sectionColumnHeights[attributes.columnIndex] integerValue] > (self.sectionInset.top + self.headerReferenceSize.height)) {
        yPosition = yPosition + self.minimumLineSpacing;
    }
    
    return yPosition;
}

- (NSUInteger)columnSpanForItemWithAttributes:(HYDCollectionViewMasonryLayoutAttributes *)attributes {
    
    NSUInteger columnSpan = 1;
    CGFloat totalColumnWidth = 0;
    
    for (NSUInteger i=0; i < self.numberOfColumns; i++) {
        totalColumnWidth += (i == 0) ? self.columnWidth : self.columnWidth + self.minimumInteritemSpacing;
        if (attributes.size.width > totalColumnWidth) {
            columnSpan++;
        }
    }
    
    return (columnSpan > self.numberOfColumns) ? self.numberOfColumns : columnSpan;
}

- (void)configureColumnWidth {
    
    CGFloat netWidth = CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.left - self.sectionInset.right;
    self.columnWidth = floor((netWidth - (self.minimumInteritemSpacing * (self.numberOfColumns -1))) / self.numberOfColumns);
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
    
    // Configure column heights
    
    NSMutableArray *heights = [NSMutableArray arrayWithCapacity:self.numberOfColumns];
    for (NSUInteger i=0; i < self.numberOfColumns; i++) {
        heights[i] = @(floor(self.sectionInset.top + self.headerReferenceSize.height));
        self.columnHeights[@(section)] = heights;
    }
}

- (void)headerSizeForSectionAtIndex:(NSUInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        self.headerReferenceSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
    }
}

- (void)footerSizeForSectionAtIndex:(NSUInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        self.footerReferenceSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
    }
}

@end
