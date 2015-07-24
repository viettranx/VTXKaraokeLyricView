//
//  RootViewController.m
//  DemoLyricPlayerWithMusic
//
//  Created by Tran Viet on 7/24/15.
//  Copyright (c) 2015 Viettranx. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "RootViewController.h"
#import "AboutViewController.h"
#import "PlayMusicViewController.h"

#import "VTXLyricParser.h"
//#import "VTXLyric.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Thái bình mồ hôi rơi";
            cell.detailTextLabel.text = @"Sơn Tùng";
            break;
            
        case 1:
            cell.textLabel.text = @"My everything";
            cell.detailTextLabel.text = @"Tiên Tiên";
            break;
        
        case 2:
            cell.textLabel.text = @"About";
            cell.detailTextLabel.text = @"About me";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *destinationVC;
    
    if(indexPath.row == 2) {
        destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutVC"];
    } else {
        PlayMusicViewController *pmvc = [self.storyboard instantiateViewControllerWithIdentifier:@"playMusicVC"];
        VTXLyricParser *lyricParser = [[VTXBasicLyricParser alloc] init];
        
        
        if(indexPath.row == 0) {
            
            NSURL *fileURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"tbmhr" ofType:@"mp3"]];

            pmvc.songURL = fileURL;
            pmvc.lyric = [lyricParser lyricFromLocalPathFileName:@"thai_binh_mo_hoi_roi"];
            
        } else if(indexPath.row == 1) {
            NSURL *fileURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"my_everything" ofType:@"mp3"]];
            
            pmvc.songURL = fileURL;
            pmvc.lyric = [lyricParser lyricFromLocalPathFileName:@"my_everything"];
            
        }
        
        destinationVC = pmvc;
    }
    
    [self.navigationController pushViewController:destinationVC animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
