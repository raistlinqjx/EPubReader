//
//  BookCell.m
//  EPubReader
//
//  Created by apple QJX on 12-6-15.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import "BookCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation BookCell
@synthesize mainLabel, subLabel, imageView;

- (void)awakeFromNib{
    backGroundImageView.layer.masksToBounds = YES;
    backGroundImageView.layer.cornerRadius = 10.0;
}


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void)dealloc{
    [mainLabel release];
    mainLabel = nil;
    [subLabel release];
    subLabel = nil;
    [imageView release];
    imageView = nil;
    [backGroundImageView release];
    backGroundImageView = nil;
    [super dealloc];
}

@end
