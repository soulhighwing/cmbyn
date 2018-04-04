//
//  DialViewController.m
//  cmbyn
//
//  Created by haiying cao on 4/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import "DialViewController.h"
#define foo4random() (arc4random() % ((unsigned)99999999 + 1))

@interface DialViewController ()

@end

@implementation DialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//a simple generate to create fake calls on history data
- (IBAction)generateRandomCall:(id)sender{
     NSDictionary* randomCall = @{@"fullName":@"",
                                 @"firstName":@"",
                                 @"lastName":@"",
                                 @"userImage":[UIImage imageNamed:@"unknow.jpg"],
                                 @"VoIPNumber":[NSString stringWithFormat:@"%u",foo4random()],
                                 @"callTime":@""
                                 };
    
    //Post message for calling tell historytable to update
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"newCalling" object:nil userInfo:randomCall];
    //post message to let historyview reload data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHistory" object:nil];
    

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
