//
//  HomeViewController.h
//  EPubReader
//
//  Created by apple QJX on 12-6-15.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCell.h"

@interface HomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *_tableView;
    NSArray *array;
    BookCell *bookCell;
}
@property (nonatomic, retain) NSArray *array;
@end
