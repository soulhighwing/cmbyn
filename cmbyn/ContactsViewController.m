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
    //locate the arraies
    allContactsArray = [[ContactList sharedContacts]allContactsArray];
    voipContactsArray = [[ContactList sharedContacts]voipContactsArray];
    
   // NSLog(@"all: %ld  voip:%ld",allContactsArray.count,voipContactsArray.count);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView:)
                                                 name:@"reloadContacts"
                                               object:nil];
}

//when switch between all contacts and VoIP only, we need reload the data
- (IBAction)reloadTableView:(id)sender {
    [contactsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //get the cell
    static NSString *CellIdentifier = @"ContactCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //fill the cell
    cell.textLabel.text = self.currentArray[indexPath.row][@"fullName"];
    cell.detailTextLabel.text = self.currentArray[indexPath.row][@"VoIPNumber"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.currentArray.count;
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
    //when select one row make a call
    UIAlertController* alert;
    UIAlertAction* defaultAction ;
    //check the existence of voip number first
    if([self.currentArray[indexPath.row][@"VoIPNumber"] isEqualToString:[NSString stringWithFormat:@""]]){
        //warning for not have voip number
        alert = [UIAlertController alertControllerWithTitle:@"ERROR"
                                                    message:@"You need add a VoIP Number for the contact before calling."
                                             preferredStyle:UIAlertControllerStyleAlert];
       defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
    }else{
        //an alert message to emulate the call and post the notice to other views
          alert = [UIAlertController alertControllerWithTitle:@"CALLING"
                                                      message:@"This is a fake VoIP call. Add real calling code here."
                                               preferredStyle:UIAlertControllerStyleAlert];
        defaultAction = [UIAlertAction actionWithTitle:@"DONE" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   //Post message for calling tell historytable to update
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:
                                                                    @"newCalling" object:nil userInfo:self.currentArray[indexPath.row]];
                                                                   //post message to let historyview reload data
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHistory" object:nil];
                                                                   
                                                               }];
        
   }
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//tap accessory = edit info
- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //load an edit controller for edit the contact name and voip number
    if(editController == nil ){
        static NSString *editControllerIdentifier=@"editContactViewController";
        editController = [self.storyboard instantiateViewControllerWithIdentifier:editControllerIdentifier];
    }
    [self presentViewController:editController animated:YES completion:^{
    }];
    //after the edit viewcontroller loaded we need set the correct value for it
    [editController updateViewUsing:self.currentArray[indexPath.row][@"ID"] withFirstName:self.currentArray[indexPath.row][@"firstName"] withLastName:self.currentArray[indexPath.row][@"lastName"] withVoIPNumber:self.currentArray[indexPath.row][@"VoIPNumber"]];
}

// swipe to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        //we need two different type of delete: whole contact or voip number only
        //show an alert for user to chose
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"DELETE"
                                                                       message:@"Delete whole contact from SYSTEM CONTACTS or remove VoIP number only?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        UIAlertAction* delWholeAction = [UIAlertAction actionWithTitle:@"WHOLE" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   //delete whole contact
                                                                   if([[ContactList sharedContacts]delContactBy:self.currentArray[indexPath.row][@"ID"]]){
                                                                       //remove single row
                                                                       [contactsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                                   }
                                                                   
                                                               }];
        UIAlertAction* delVoIPAction = [UIAlertAction actionWithTitle:@"VoIP Number" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //remove voip number only
                                                                    if([[ContactList sharedContacts]updateExistContactBy:self.currentArray[indexPath.row][@"ID"] withFirst:self.currentArray[indexPath.row][@"firstName"] withLast:self.currentArray[indexPath.row][@"lastName"] withVoIP:@""]){
                                                                       //reload single row
                                                                      [contactsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];

                                                                  }
                                                                  
                                                                  
                                                                }];
        [alert addAction:delWholeAction];
        [alert addAction:delVoIPAction];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

//return the correct array base on the switch
-(NSMutableArray *)currentArray{
    if(showVoIPOnly.selectedSegmentIndex == 0){
        return allContactsArray;
    }
    else{
        return voipContactsArray;
    }
}


 #pragma mark - Notification
 


@end
