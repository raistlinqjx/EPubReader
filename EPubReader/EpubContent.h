//
//  EpubContent.h
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpubContent : NSObject{
    NSMutableDictionary *_manifest;
    NSMutableArray *_spine;
}
@property (nonatomic, retain) NSMutableDictionary *_manifest;
@property (nonatomic, retain) NSMutableArray *_spine;
@end
