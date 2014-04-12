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

@interface HYDMasonryLayoutViewController () <UICollectionViewDataSource, HYDCollectionViewMasonryLayoutDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;

@property (nonatomic, strong) NSMutableArray *elements;

@end

@implementation HYDMasonryLayoutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createElements];
    [self registerNibs];
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

#pragma mark - HYDCollectionViewMasonryLayoutDelegate conformance

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return (UIInterfaceOrientationIsPortrait(orientation)) ? 4 : 5;
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
    
    return 0.f;
}

#pragma mark - Private Methods

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
    }];
}

- (void)registerNibs {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HYDElementCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HYDElementCell class])];
}

@end
