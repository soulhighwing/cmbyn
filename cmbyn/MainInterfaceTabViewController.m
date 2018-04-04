//
//  MainInterfaceTabViewController.m
//  cmbyn
//
//  Created by haiying cao on 31/03/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import "MainInterfaceTabViewController.h"
#import "ContactList.h"

@interface MainInterfaceTabViewController ()

@end

@implementation MainInterfaceTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[ContactList sharedContacts] fetchAllContacts]; // first time fetch

 }
- (void)viewDidAppear:(BOOL)animated{
    //refresh all data because contacts could be changed here
    //we monitor the access to contacts all the time
    //every time the view apear we need to know if we still have access
    //if not we go fectch(check and request )
    if([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized){
        [self getPermissionFromUser];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getPermissionFromUser {
    // The user has previously denied access
    // Send an alert telling user to change privacy setting in settings app
    
    // Permission not given so move user in settings page to app.
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* SettingsButton = [UIAlertAction actionWithTitle:@"Settings"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         NSURL * settingsURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",UIApplicationOpenSettingsURLString,[[NSBundle mainBundle]bundleIdentifier]]];
                                         
                                         if (settingsURL) {
                                             [[UIApplication sharedApplication] openURL:settingsURL
                                                                                options:[NSDictionary dictionary] completionHandler:nil];
                                         }
                                     }];
    
    UIAlertAction* DeniedButton = [UIAlertAction actionWithTitle:@"Denied"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    
    [alert addAction:SettingsButton];
    [alert addAction:DeniedButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    NSLog(@"Get Permission from User");
}





@end
