//
//  BookCell.h
//  EPubReader
//
//  Created by apple QJX on 12-6-15.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCell : UITableViewCell{
    UILabel *mainLabel;
    UILabel *subLabel;
    UIImageView *imageView;
    IBOutlet UIImageView *backGroundImageView;
}
@property (nonatomic, retain) IBOutlet UILabel *mainLabel;
@property (nonatomic, retain) IBOutlet UILabel *subLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@end
