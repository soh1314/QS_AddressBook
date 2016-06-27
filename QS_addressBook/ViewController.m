//
//  ViewController.m
//  QS_addressBook
//
//  Created by jingshuihuang on 16/6/27.
//  Copyright © 2016年 QS. All rights reserved.
//

#import "ViewController.h"
#import "JRAddressBook.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JRAddressBook requestAuthorize:^{
        NSLog(@"notDetermined");
    } authorized:^{
        NSLog(@"authorize");
    } other:^{
        NSLog(@"other");
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
