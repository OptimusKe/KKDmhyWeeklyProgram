//
//  DayProgram.h
//  KKDmhyWeeklyProgram
//
//  Created by Jack on 2014/10/23.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayProgram : NSObject

@property(nonatomic , strong) NSString *imageUrl;
@property(nonatomic , strong) NSString *animeName;
@property(nonatomic , strong) NSString *searchLink;
@property(nonatomic , strong) NSMutableArray *fansubsArray;
@property(nonatomic , strong) NSString *officialSite;

- (id)initWithSource:(NSString *)source;

@end
