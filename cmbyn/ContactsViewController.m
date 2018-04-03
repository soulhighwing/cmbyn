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
    
    allContactsArray = [[ContactList sharedContacts]allContactsArray];
    voipContactsArray = [[ContactList sharedContacts]voipContactsArray];
    NSLog(@"all: %ld  voip:%ld",allContactsArray.count,voipContactsArray.count);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView:)
                                                 name:@"reloadContacts"
                                               object:nil];
}


- (IBAction)reloadTableView:(id)sender {
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.currentArry[indexPath.row][@"fullName"];
    cell.detailTextLabel.text = self.currentArry[indexPath.row][@"VoIPNumber"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.currentArry.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
//select row = make call
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check the existence of voip number first
    UIAlertController* alert;
    UIAlertAction* defaultAction ;
    if([self.currentArry[indexPath.row][@"VoIPNumber"] isEqualToString:[NSString stringWithFormat:@""]]){
        //warning for not have voip number
        alert = [UIAlertController alertControllerWithTitle:@"ERROR"
                                                    message:@"You need add a VoIP Number for the contact before calling."
                                             preferredStyle:UIAlertControllerStyleAlert];
       defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
    }else{
        
          alert = [UIAlertController alertControllerWithTitle:@"CALLING"
                                                      message:@"This is a fake VoIP call. Add real calling code here."
                                               preferredStyle:UIAlertControllerStyleAlert];
        defaultAction = [UIAlertAction actionWithTitle:@"DONE" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   //Post message for calling tell contactlist to update
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:
                                                                    @"newCalling" object:nil userInfo:self.currentArry[indexPath.row]];
                                                                   
                                                               }];
   }
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//tap accessory = edit info
- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    if(editController == nil ){
        static NSString *editControllerIdentifier=@"editContactViewController";
        editController = [self.storyboard instantiateViewControllerWithIdentifier:editControllerIdentifier];
    }
    [self presentViewController:editController animated:YES completion:^{
    }];

    [editController updateViewUsing:self.currentArry[indexPath.row][@"ID"] withFirstName:self.currentArry[indexPath.row][@"firstName"] withLastName:self.currentArry[indexPath.row][@"lastName"] withVoIPNumber:self.currentArry[indexPath.row][@"VoIPNumber"]];
}

// swipe to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"DELETE"
                                                                       message:@"Delete whole contact info or VoIP number only?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        UIAlertAction* delWholeAction = [UIAlertAction actionWithTitle:@"WHOLE" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   if([[ContactList sharedContacts]delContactBy:self.currentArry[indexPath.row][@"ID"]]){
                                                                       [contactsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                                   }
                                                                   
                                                               }];
        UIAlertAction* delVoIPAction = [UIAlertAction actionWithTitle:@"VoIP Number" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                    if([[ContactList sharedContacts]updateExistContactBy:self.currentArry[indexPath.row][@"ID"] withFirst:self.currentArry[indexPath.row][@"firstName"] withLast:self.currentArry[indexPath.row][@"lastName"] withVoIP:@""]){
                                                                      [contactsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];

                                                                  }
                                                                  
                                                                  
                                                                }];
        [alert addAction:delWholeAction];
        [alert addAction:delVoIPAction];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

-(NSMutableArray *)currentArry{
    if(showVoIPOnly.selectedSegmentIndex == 0){
        return allContactsArray;
    }
    else{
        return voipContactsArray;
    }
}


 #pragma mark - Notification
 


@end
