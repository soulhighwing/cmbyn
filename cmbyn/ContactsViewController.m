//
//  ContactsViewController.m
//  cmbyn
//
//  Created by haiying cao on 1/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactList.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController
@synthesize showVoIPOnly;
@synthesize contactsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[ContactList sharedContacts] fetchAllContacts]; // fetch all contacts by calling single to method
    
    if ([[ContactList sharedContacts]allContactsArray].count !=0) {
        NSLog(@"Fetched Contact Details : %ld",[[ContactList sharedContacts]allContactsArray].count);
    }
  }

-(IBAction)switchedVoIPList:(id)sender{
    //refresh tableview when switched to voiplist or switch back
    [contactsTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - contacts access

#pragma mark - Table view
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(showVoIPOnly.selectedSegmentIndex == 0){
    cell.textLabel.text = [[ContactList sharedContacts]allContactsArray][indexPath.row][@"fullName"];
    cell.detailTextLabel.text = [[ContactList sharedContacts]allContactsArray][indexPath.row][@"VoIPNumber"];
    }
    else{
        cell.textLabel.text = [[ContactList sharedContacts]voipContactsArray][indexPath.row][@"fullName"];
        cell.detailTextLabel.text = [[ContactList sharedContacts]voipContactsArray][indexPath.row][@"VoIPNumber"];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(showVoIPOnly.selectedSegmentIndex == 0){
        return [[ContactList sharedContacts]allContactsArray].count;
    }
    else{
        return [[ContactList sharedContacts]voipContactsArray].count;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
