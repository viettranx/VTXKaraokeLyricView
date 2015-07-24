//
//  ViewController.m
//  DemoLyricPlayerWithMusic
//
//  Created by Tran Viet on 7/23/15.
//  Copyright (c) 2015 Viettranx. All rights reserved.
//

#import "AboutViewController.h"
#import "VTXLyricPlayerView.h"
#import "VTXKaraokeLyricView.h"

@interface AboutViewController ()<VTXLyricPlayerViewDataSource>
{
    NSDictionary *contents;
    NSArray *keysTiming;
}
@property (weak, nonatomic) IBOutlet VTXLyricPlayerView *lyricPlayerView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lyricPlayerView.dataSource = self;
    
    contents = @{
                 @"0.0" : @"Hello everybody",
                 @"1.0" : @"I am Viettranx",
                 @"2.5" : @"",
                 @"4.5": @"Just use my engine for free",
                 @"7.0": @"Contact me for any question",
                 @"11.5": @"",
                 @"13.0": @"viettranx@gmail.com",
                 @"15.0": @""
                 };
    
    // sort key from nsdictionary
    NSArray* keys = [contents allKeys];
    keysTiming = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.lyricPlayerView prepareToPlay];
    [self.lyricPlayerView start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Implement data source
- (NSArray* )timesForLyricPlayerView:(VTXLyricPlayerView *)lpv {
    
    return keysTiming;
}

- (VTXKaraokeLyricView *)lyricPlayerView:(VTXLyricPlayerView *)lpv lyricAtIndex:(NSInteger)index {
    
    VTXKaraokeLyricView *lyricView = [lpv reuseLyricView];
    // Config lyric view
    lyricView.textColor = [UIColor whiteColor];
    [lyricView setFillTextColor:[UIColor redColor]];
    lyricView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
    
    NSString *key = [keysTiming objectAtIndex:index];
    lyricView.text = [contents objectForKey:key];
    
    return lyricView;
}

- (BOOL)lyricPlayerView:(VTXLyricPlayerView *)lpv allowLyricAnimationAtIndex:(NSInteger)index {
    return YES;
}


@end
