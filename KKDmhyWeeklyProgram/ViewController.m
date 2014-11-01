//
//  ViewController.m
//  KKDmhyWeeklyProgram
//
//  Created by Jack on 2014/10/23.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "Anime.h"
#import "DaysHeaderView.h"
#import "AnimeCell.h"
#import "UIImageView+WebCache.h"
#import "FansubTableViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kMargin 0
#define kCellScaleRatio (181.0 / 100.0)

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>{
    
    NSMutableArray *weeklyProgramArray;
    NSMutableArray *programArray;
}

@property (nonatomic , weak) IBOutlet UICollectionView *animeCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Dmhy番組表";
    programArray = [NSMutableArray array];
    
    NSString *dictPath = [[NSBundle mainBundle] pathForResource:@"program" ofType:@"plist"];
    weeklyProgramArray = [NSMutableArray arrayWithContentsOfFile:dictPath];
    
    //layout setting
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.frame), 50);
    self.animeCollectionView.collectionViewLayout = layout;
    
    //register header
    UINib *headerNib = [UINib nibWithNibName:@"DaysHeaderView" bundle:nil];
    [self.animeCollectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DaysHeaderView"];
    
    //register cell
    UINib *cellNib = [UINib nibWithNibName:@"AnimeCell" bundle:nil];
    [self.animeCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"AnimeCell"];

    
    //get html
    [self loadDmhyHtml];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - action

- (void)loadDmhyHtml{
    
    [self.navigationController setIndeterminate:YES];
    self.navigationItem.rightBarButtonItem = nil;
    
    NSString* url = @"http://share.dmhy.org/cms/page/name/programme.html";
    
    __weak typeof(self) weakSelf = self;
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [weakSelf.navigationController setIndeterminate:NO];
        
        NSString *responseString = [weakRequest responseString];
        [weakSelf parseSource:responseString];
    }];
    [request setFailedBlock:^{
        //disable loading animation
        [weakSelf.navigationController setIndeterminate:NO];
        
        //retry buttom
        UIBarButtonItem* retryBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadDmhyHtml)];
        weakSelf.navigationItem.rightBarButtonItem = retryBtn;
    }];
    [request startAsynchronous];
}

- (void)parseSource:(NSString *)htmlSource{
    
    /*
     ['圖片','動畫名','直接搜索連結','字幕組','官方公式']  範例：
     ___array.push(['http://share.dmhy.org/images/weekly/dragon.gif','龍珠．改','%E9%bE%8D%E7%8f%A0','<a href="/topics/list?keyword=%E9%bE%8D%E7%8f%A0+team_id%3A241">幻櫻</a>','http://abc.com']);
     */
    
    /*
     http://share.dmhy.org/images/weekly/OnePiece.jpg
    
     海賊王(航海王)
    
     海賊王
    
     <a href="/topics/list?keyword=海賊王+team_id:34">楓雪連載</a><a href="/topics/list?keyword=海賊王+team_id:57">月光戀曲</a><a href="/topics/list?keyword=海賊王+team_id:380">豬豬</a><a href="/topics/list?keyword=海賊王+team_id:485">天空樹</a><a href="/topics/list?keyword=海賊王+team_id:506">銀光</a>
    
     http://www.toei-anim.co.jp/tv/onep/
     */

    
    for(NSDictionary *dayDict in weeklyProgramArray){
        
        NSString *regexName = [dayDict objectForKey:@"RegexName"];
        
        NSMutableArray *dayProgramArray = [NSMutableArray array];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@.push(.*);",regexName]
                                                                               options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *regexMatches = [regex matchesInString:htmlSource options:0 range:NSMakeRange(0, htmlSource.length)];
        
        for (int i = 0; i < regexMatches.count ;i++) {
            
            NSTextCheckingResult *match = [regexMatches objectAtIndex:i];
            
            NSString *animeData = [htmlSource substringWithRange:match.range];
            
            animeData = [animeData stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.push([",regexName] withString:@""];
            animeData = [animeData stringByReplacingOccurrencesOfString:@"]);" withString:@""];
            animeData = [animeData stringByReplacingOccurrencesOfString:@"'" withString:@""];
            animeData = [animeData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
            
            Anime *anime = [[Anime alloc] initWithSource:animeData];
            [dayProgramArray addObject:anime];
        }
        
        [programArray addObject:dayProgramArray];
    }
    


    [self.animeCollectionView reloadData];
    
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(programArray.count > 0){
        
        NSMutableArray *dayProgramArray = [programArray objectAtIndex:section];
        if(dayProgramArray.count > 0){
            return dayProgramArray.count;
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    if(programArray.count > 0){
        return programArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AnimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimeCell" forIndexPath:indexPath];
    NSMutableArray *dayProgramArray = [programArray objectAtIndex:indexPath.section];
    Anime *anime = [dayProgramArray objectAtIndex:indexPath.row];
    cell.title.text = anime.animeName;
    NSDictionary *dayDict = [weeklyProgramArray objectAtIndex:indexPath.section];
    cell.title.backgroundColor = [self colorFromHexString:[dayDict objectForKey:@"Color"]];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:anime.imageUrl]
                  placeholderImage:nil options:SDWebImageRefreshCached];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
        DaysHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DaysHeaderView" forIndexPath:indexPath];
        
        
        NSDictionary *dayDict = [weeklyProgramArray objectAtIndex:indexPath.section];
        headerView.title.text = [dayDict objectForKey:@"Title"];
        headerView.backgroundColor = [self colorFromHexString:[dayDict objectForKey:@"Color"]];
        
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray *dayProgramArray = [programArray objectAtIndex:indexPath.section];
    Anime *anime = [dayProgramArray objectAtIndex:indexPath.row];
 
    FansubTableViewController *controller = [[FansubTableViewController alloc] init];
    controller.anime = anime;
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat width = CGRectGetWidth(self.view.frame) / 3.0;
    
    
    CGSize cellSize = CGSizeMake(width , width * kCellScaleRatio);
    
    return cellSize;
}

#pragma mark - color

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
