//
//  HistoryTableViewController.m
//  cmbyn
//
//  Created by haiying cao on 4/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "ContactList.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    historyArray = [[ContactList sharedContacts]historyArray];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView:)
                                                 name:@"reloadHistory"
                                               object:nil];
    
}
- (void)reloadTableView:(id)sender {
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HistoryCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", historyArray[indexPath.row][@"fullName"],historyArray[indexPath.row][@"VoIPNumber"]];
    cell.detailTextLabel.text = historyArray[indexPath.row][@"callTime"];
    cell.imageView.image = historyArray[indexPath.row][@"userImage"];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return historyArray.count;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ContactList sharedContacts] delOneHistoryCall:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check the existence of voip number first
    UIAlertController* alert;
    UIAlertAction* defaultAction ;
    alert = [UIAlertController alertControllerWithTitle:@"CALLING"
                                                message:@"This is a fake VoIP call. Add real calling code here."
                                         preferredStyle:UIAlertControllerStyleAlert];
    defaultAction = [UIAlertAction actionWithTitle:@"DONE" style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Post message for calling tell historyarray to update
                                               [[NSNotificationCenter defaultCenter] postNotificationName:
                                                @"newCalling" object:nil userInfo:historyArray[indexPath.row]];
                                               //refresh view
                                                [self.tableView reloadData];
                                               
                                           }];
    
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
    
    [editController updateViewUsing:historyArray[indexPath.row][@"ID"] withFirstName:historyArray[indexPath.row][@"firstName"] withLastName:historyArray[indexPath.row][@"lastName"] withVoIPNumber:historyArray[indexPath.row][@"VoIPNumber"]];
}

@end
