//
//  Anime.h
//  KKDmhyWeeklyProgram
//
//  Created by OptimusKe on 2014/11/1.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Anime : NSObject

@property(nonatomic , strong) NSString *imageUrl;
@property(nonatomic , strong) NSString *animeName;
@property(nonatomic , strong) NSString *searchLink;
@property(nonatomic , strong) NSMutableArray *fansubsArray;
@property(nonatomic , strong) NSString *officialSite;

- (id)initWithSource:(NSString *)source;

@end
