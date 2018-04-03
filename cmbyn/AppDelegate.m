//
//  AppDelegate.m
//  cmbyn
//
//  Created by haiying cao on 31/03/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "HelpScreenViewController.h"
#import "MainInterfaceTabViewController.h"
#import "ContactList.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //use NSUSERDEFAULTS TO SAVE THE HELPSCREEN STATE
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"showHelp"]) {
        NSLog(@"showHelp");
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpScreen"];
        self.window.rootViewController = viewController;
    }else {
        NSLog(@"Not show help");
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainInterface"];
        self.window.rootViewController = viewController;
    }

    [self.window makeKeyAndVisible];
 
    
    [[ContactList sharedContacts] fetchAllContacts]; // fetch all contacts by calling single to method

    /*
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"showHelp"]) {

        HelpScreenViewController *vc = [[HelpScreenViewController alloc] init];
        self.window.rootViewController = vc;
    }else {
        NSLog(@"Not show help");
        MainInterfaceTabViewController *vc = [[MainInterfaceTabViewController alloc] init];
        self.window.rootViewController = vc;
    }
*/
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
