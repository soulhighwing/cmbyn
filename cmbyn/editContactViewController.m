//
//  editContactViewController.m
//  cmbyn
//
//  Created by haiying cao on 2/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import "editContactViewController.h"
#import "ContactList.h"

@interface editContactViewController ()

@end

@implementation editContactViewController

@synthesize firstNameField;
@synthesize lastNameField;
@synthesize voipNumberField;
@synthesize identifierString;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewUsing:(NSString *)identifier withFirstName:(NSString *)firstName withLastName:(NSString *)lastName withVoIPNumber:(NSString *)voipNumber{
    identifierString = identifier;
    firstNameField.text = firstName;
    lastNameField.text = lastName;
    voipNumberField.text = voipNumber;
}

-(IBAction)saveContact:(id)sender{
    if(identifierString == nil){
        if([[ContactList sharedContacts]addContact:firstNameField.text withLast:lastNameField.text withVoIP:voipNumberField.text]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContacts" object:self];
        }
    }
    else{
        if([[ContactList sharedContacts]updateExistContactBy:identifierString withFirst:firstNameField.text withLast:lastNameField.text withVoIP:voipNumberField.text]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContacts" object:self];
        }
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)cancelEdit:(id)sender{
     [self dismissViewControllerAnimated:YES completion:nil];
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
