//
//  HYDElementCell.h
//  HYDGridLayout
//
//  Created by Simon Hall on 22/03/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYDElementCell : UICollectionViewCell

@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, weak, readonly) UILabel *elementSymbolLabel;
@property (nonatomic, weak, readonly) UILabel *elementNameLabel;
@property (nonatomic, weak, readonly) UILabel *elementNumberLabel;

@end
