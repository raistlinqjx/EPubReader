//
//  EpubContent.m
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import "EpubContent.h"

@implementation EpubContent
@synthesize _spine, _manifest;

- (void)dealloc{
    [_manifest release];
    _manifest = nil;
    [_spine release];
    _spine = nil;
    [super dealloc];
}
@end
