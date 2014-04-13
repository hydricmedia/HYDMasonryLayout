//
//  HYDElementCell.m
//  HYDGridLayout
//
//  Created by Simon Hall on 22/03/2014.
//  Copyright (c) 2014 Simon Hall. All rights reserved.
//

#import "HYDElementCell.h"


@interface HYDElementCell ()

@property (nonatomic, weak) IBOutlet UIView *elementContainer;
@property (nonatomic, weak) IBOutlet UILabel *elementSymbolLabel;
@property (nonatomic, weak) IBOutlet UILabel *elementNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *elementNumberLabel;

@end

@implementation HYDElementCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureAppearance];
}

#pragma mark - Private methods

- (void)configureAppearance {
    
//    self.elementContainer.layer.cornerRadius = 6.f;
//    self.elementContainer.layer.shadowOffset = CGSizeMake(1.0, 1.0);
//    self.elementContainer.layer.shadowOpacity = 0.5f;
//    self.elementContainer.layer.shadowColor = [UIColor colorWithWhite:0.5f alpha:1.0].CGColor;
//    self.elementContainer.layer.shadowRadius = 2.f;
    self.elementContainer.layer.borderWidth = 1.f;
    self.elementContainer.layer.borderColor = [UIColor yellowColor].CGColor;
}

- (void)setElementName:(NSString *)elementName {
    
    _elementName = elementName;
    
    NSRange range = [elementName rangeOfString:@"ium"];
    
    if (range.length == 0) {
        self.elementContainer.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    } else {
        self.elementContainer.backgroundColor = [UIColor blueColor];
    }
}

@end
