//
//  DayProgram.m
//  KKDmhyWeeklyProgram
//
//  Created by Jack on 2014/10/23.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import "DayProgram.h"
#import "TFHpple.h"

@interface DayProgram (){

}

@end

@implementation DayProgram

- (id)initWithSource:(NSString *)source{

    if(self = [super init]){
        [self setup:source];
    }
    
    return self;
}

- (void)setup:(NSString *)source{
    
    /*
     ['圖片','動畫名','直接搜索連結','字幕組','官方公式']  範例：
     ___array.push(['http://share.dmhy.org/images/weekly/dragon.gif','龍珠．改','%E9%bE%8D%E7%8f%A0','<a href="/topics/list?keyword=%E9%bE%8D%E7%8f%A0+team_id%3A241">幻櫻</a>','http://abc.com']);
     */
    NSArray* detailArray = [source componentsSeparatedByString:@","];

    self.imageUrl = [detailArray objectAtIndex:0];
    self.animeName = [detailArray objectAtIndex:1];
    self.searchLink = [detailArray objectAtIndex:2];
    
    NSString* subSource = [detailArray objectAtIndex:3];
    self.fansubsArray = [NSMutableArray array];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:[subSource dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray * elements  = [doc searchWithXPathQuery:@"//a"];
    
    for(TFHppleElement* ele in elements){
        NSString *fansubLink = [ele objectForKey:@"href"];
        fansubLink = [NSString stringWithFormat:@"http://share.dmhy.org/%@",fansubLink];
        NSString *encodingLink = [fansubLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *fansubTitle = [ele text];
        
        [self.fansubsArray addObject:@{@"Title" : fansubTitle,
                                       @"Link"  : encodingLink}];
    }
    
    self.officialSite = [detailArray objectAtIndex:4];
}




@end
