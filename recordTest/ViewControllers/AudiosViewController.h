//
//  AudiosViewController.h
//  recordTest
//
//  Created by YAO DONG LI on 24/1/15.
//  Copyright (c) 2015 ThreeStones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudiosViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *Audios;
@end