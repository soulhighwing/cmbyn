//
//  ContactsViewController.h
//  cmbyn
//
//  Created by haiying cao on 1/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "editContactViewController.h"

@interface ContactsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *allContactsArray; //Total Mobile Contacts from access from this variable
    NSMutableArray *voipContactsArray; //Contacts with voip
    
    editContactViewController *editController;

}
@property (weak,nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak,nonatomic) IBOutlet UISegmentedControl *showVoIPOnly;
-(IBAction)switchedVoIPList:(id)sender;
@end
