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

@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) NSMutableArray *things;

@end

@implementation HYDMasonryLayoutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createElements];
    [self createThings];

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

- (NSMutableArray *)things
{
    if (!_things) {
        _things = [NSMutableArray new];
    }
    
    return _things;
}

#pragma mark - UICollectionViewDataSource conformance

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return [self.elements count];
        case 1:
            return [self.things count];
        default:
            return 0;
    }
}

#pragma mark - UICollectionViewDelegate conformance

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYDElementCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HYDElementCell class]) forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HYDHeaderCell" forIndexPath:indexPath];
    }
    
    UICollectionReusableView *footerView;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        if (indexPath.section == 0) {
            footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HYDFooterCell" forIndexPath:indexPath];
            footerView.backgroundColor = [UIColor lightGrayColor];
            return footerView;
        } else {
            footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HYDFooterCell" forIndexPath:indexPath];
            footerView.backgroundColor = [UIColor blueColor];
            return footerView;
        }
    }
    
    return nil;
}

#pragma mark - HYDCollectionViewMasonryLayoutDelegate conformance

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
    
    if (IPHONE) {
        return 1;
    } else {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        return (UIInterfaceOrientationIsPortrait(orientation)) ? 4 : 5;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if (IPHONE) {
        return UIEdgeInsetsMake(10.f, 5.f, 10.f, 5.f);
    } else {
        return UIEdgeInsetsMake(20.f, 10.f, 20.f, 10.f);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYDCollectionViewMasonryLayout *layout = (HYDCollectionViewMasonryLayout *)collectionViewLayout;
    
    if (indexPath.section == 0) {
        
        HYDElement *element = self.elements[indexPath.item];
        
        if (IPHONE) {
            return CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - layout.sectionInset.left - layout.sectionInset.right, element.elementHeight);
        } else {
            return CGSizeMake(element.elementWidth, element.elementHeight);
        }
    }
    
    if (indexPath.section == 1) {
        
        HYDElement *element = self.things[indexPath.item];
        
        if (IPHONE) {
            return CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - layout.sectionInset.left - layout.sectionInset.right, element.elementHeight);
        } else {
            return CGSizeMake(element.elementWidth, element.elementHeight);
        }
    }
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), 200.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), 100.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

#pragma mark - Helpers

- (void)configureCell:(HYDElementCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    HYDElement *element;
    if (indexPath.section == 0) {
        element = self.elements[indexPath.item];
    } else {
        element = self.things[indexPath.item];
    }
    
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

- (void)createThings {
    
    NSError *error;
    NSString *fileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"thingsdump.csv" ofType:nil] encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    NSArray *fileArray = [fileString componentsSeparatedByString:@"\n"];
    [fileArray enumerateObjectsUsingBlock:^(NSString *elementsLine, NSUInteger idx, BOOL *stop) {
        NSArray *lineArray = [elementsLine componentsSeparatedByString:@","];
        HYDElement *element = [[HYDElement alloc] initWithLineArray:lineArray];
        [self.things addObject:element];
        NSLog(@"%@", [element descriptionWithWidthAndHeight]);
    }];
}

- (void)registerNibs {
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HYDElementCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HYDElementCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HYDHeaderCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HYDHeaderCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HYDFooterCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HYDFooterCell"];
}

@end
