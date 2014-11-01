//
//  FansubTableViewController.m
//  KKDmhyWeeklyProgram
//
//  Created by OptimusKe on 2014/11/1.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import "FansubTableViewController.h"
#import "SVWebViewController.h"

#define CellIdentifier @"Cell"

@interface FansubTableViewController (){
}

@end

@implementation FansubTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.title = self.dayProgram.animeName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(self.dayProgram){
        return self.dayProgram.fansubsArray.count;
    }
        
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *fansubDict = [self.dayProgram.fansubsArray objectAtIndex:indexPath.row];
    
    if(fansubDict){
        cell.textLabel.text = fansubDict[@"Title"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *fansubDict = [self.dayProgram.fansubsArray objectAtIndex:indexPath.row];
    
    if(fansubDict){
        NSURL *URL = [NSURL URLWithString:[fansubDict objectForKey:@"Link"]];
        
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
        [self.navigationController pushViewController:webViewController animated:YES];
    }

}


@end
