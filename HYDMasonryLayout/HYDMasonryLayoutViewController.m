//
//  HYDMasonryLayoutViewController.m
//  HYDMasonryLayout
//
//  Created by Simon Hall on 12/04/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import "HYDMasonryLayoutViewController.h"
#import "HYDCollectionViewMasonryLayout.h"
#import "HYDElementCell.h"
#import "HYDElement.h"

@interface HYDMasonryLayoutViewController () <UICollectionViewDataSource, UICollectionViewDelegate, HYDCollectionViewMasonryLayoutDelegate>

@property (nonatomic, weak) IBOutlet HYDCollectionViewMasonryLayout *layout;
@property (nonatomic, weak) IBOutlet UISegmentedControl *sortSegmentedControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *filterSegmentedControl;

@property (nonatomic, strong) NSMutableArray *elements;

@end

@implementation HYDMasonryLayoutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createElements];
    [self registerNibs];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark - Accessors
- (NSMutableArray *)elements
{
    if (!_elements) {
        _elements = [NSMutableArray new];
    }
    
    return _elements;
}

#pragma mark - Actions

- (IBAction)orderChanged:(UISegmentedControl *)sender {
}

- (IBAction)filterChanged:(UISegmentedControl *)sender {
}

#pragma mark - UICollectionViewDataSource conformance

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.elements count];
}

#pragma mark - UICollectionViewDelegate conformance

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYDElementCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HYDElementCell class]) forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - HYDCollectionViewMasonryLayoutDelegate conformance

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return (UIInterfaceOrientationIsPortrait(orientation)) ? 4 : 5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(20.f, 10.f, 20.f, 10.f);
    return UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYDElement *element = self.elements[indexPath.item];
    return CGSizeMake(element.elementWidth, element.elementHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

#pragma mark - Helpers

- (void)configureCell:(HYDElementCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    HYDElement *element = self.elements[indexPath.item];
    
    cell.elementName = element.elementName;
    cell.elementNumberLabel.text = [NSString stringWithFormat:@"%d", element.elementNo];
    cell.elementNameLabel.text = element.elementName;
    cell.elementSymbolLabel.text = element.elementSymbol;
}

- (void)createElements {
    NSError *error;
    NSString *fileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"periodictabledump.csv" ofType:nil] encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    NSArray *fileArray = [fileString componentsSeparatedByString:@"\n"];
    [fileArray enumerateObjectsUsingBlock:^(NSString *elementsLine, NSUInteger idx, BOOL *stop) {
        NSArray *lineArray = [elementsLine componentsSeparatedByString:@","];
        HYDElement *element = [[HYDElement alloc] initWithLineArray:lineArray];
        [self.elements addObject:element];
        NSLog(@"%@", [element descriptionWithWidthAndHeight]);
    }];
}

- (void)registerNibs {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HYDElementCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HYDElementCell class])];
}

@end
