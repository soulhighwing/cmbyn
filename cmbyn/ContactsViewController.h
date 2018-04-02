//
//  ContactsViewController.h
//  cmbyn
//
//  Created by haiying cao on 1/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak,nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak,nonatomic) IBOutlet UISegmentedControl *showVoIPOnly;
-(IBAction)switchedVoIPList:(id)sender;
@end
