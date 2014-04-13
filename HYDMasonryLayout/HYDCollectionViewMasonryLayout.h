//
//  HYDCollectionViewMasonryLayout.h
//  HYDMasonryLayout
//
//  Created by Simon Hall on 12/04/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HYDCollectionViewMasonryLayoutDelegate;

@interface HYDCollectionViewMasonryLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) NSInteger columnIndex;
@property (nonatomic, assign) NSUInteger columnSpan;

@end

@interface HYDCollectionViewMasonryLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic, weak) IBOutlet id<HYDCollectionViewMasonryLayoutDelegate> delegate;

@end

@protocol HYDCollectionViewMasonryLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView;

@end