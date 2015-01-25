//
//  AudiosViewController.m
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import "AudiosViewController.h"
#import <BmobSDK/Bmob.h>
#import <AFNetworking.h>

#import "AudioFileCell.h"
#import <AVFoundation/AVFoundation.h>



@interface AudiosViewController () {
    NSMutableArray *cellModels;
    __weak IBOutlet UITableView *tvAudios;
    __weak IBOutlet UIActivityIndicatorView *indicator;
    
}
@property (nonatomic, strong) AVAudioPlayer *player;
@end


@implementation AudiosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"in audio VC");
    tvAudios.hidden = YES;
    [indicator startAnimating];
    cellModels = [NSMutableArray array];
    
    //config preview player
    _player = [[AVAudioPlayer alloc] init];
    
    BmobQuery *bQuery = [BmobQuery queryWithClassName:@"Audio"];
    
    
    [bQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            NSLog(@"get obj title is %@",[obj objectForKey:kAudioTitle]);
            NSLog(@"get obj url is %@",[[obj objectForKey:kAudioFile] url]);
            [cellModels addObject:obj];
        }
        [tvAudios reloadData];
        tvAudios.hidden = NO;
    }];
    
    
    //    cellModels = @[@"title 1", @"title 2", @"title 3"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma tv delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioFileCell" forIndexPath:indexPath];
    BmobObject *bObj = cellModels[indexPath.row];
    
    cell.lbTitle.text = [bObj objectForKey:kAudioTitle];
    cell.bPlay.tag = indexPath.row;
    [cell.bPlay addTarget:self action:@selector(goPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
//{
//            AudioFileCell *cell = (AudioFileCell *)[tableView cellForRowAtIndexPath:indexPath];
//    NSLog(@"select index path %li",indexPath.row);
//    NSLog(@"cell label is %@",cell.lbTitle.text);
//
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


    BmobObject *bObj = cellModels[indexPath.row];
    NSString *songName = [bObj objectForKey:kAudioTitle];
    BmobFile *songFile = [bObj objectForKey:kAudioFile];
    NSString *songURL = songFile.url;
    
    //check whether file exists
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [paths objectAtIndex:0];
    
    NSString *fileNameToBeChecked = [songURL lastPathComponent];
    NSString *filePathToBeChecked = [documentDirectoryPath stringByAppendingPathComponent:fileNameToBeChecked];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathToBeChecked]) {
        NSLog(@"file: %@ exists already", filePathToBeChecked);
        NSURL *filePath = [NSURL URLWithString:filePathToBeChecked];
        AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
        _player = tmpPlayer;
        tmpPlayer = nil;
        [_player prepareToPlay];
        [_player play];
    } else {
        //file not exists, need to download
        //download audio file mp3
        AudioFileCell *cell = (AudioFileCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        cell.indicator.hidden = NO;
        [tableView reloadData];
        NSLog(@"download file %@ with link:%@", songName, songURL);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:songURL]];
        NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            NSURL *destinationURL = [NSURL fileURLWithPath:[documentDirectoryPath stringByAppendingPathComponent:[response suggestedFilename]]];
            return destinationURL;
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"file downloaded to %@",filePath);
            //        [player url] = filePath;
            NSLog(@"error is %@",error.description);
//            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[filePath path]];
            
            cell.indicator.hidden = YES;
            [tableView reloadData];
            
            //play audio
            AVAudioPlayer *tmpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
            _player = tmpPlayer;
            tmpPlayer = nil;
            [_player prepareToPlay];
            [_player play];
            
        }];
        [downloadTask resume];
    }
}


- (void) goPressed: (UIButton *)sender
{
    
    NSLog(@"go pressed at %li",(long)sender.tag);
    //    //download audio file mp3
    //    BmobObject *bObj = cellModels[sender.tag];
    //    NSString *songName = [bObj objectForKey:kAudioTitle];
    //    BmobFile *songFile = [bObj objectForKey:kAudioFile];
    //    NSString *songURL = songFile.url;
    //    NSLog(@"play button at %ld pressed, download file %@ with link:%@",(long)sender.tag, songName, songURL);
    
}


@end
