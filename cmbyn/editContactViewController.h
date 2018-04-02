//
//  editContactViewController.h
//  cmbyn
//
//  Created by haiying cao on 2/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface editContactViewController : UIViewController
@property (weak,nonatomic) IBOutlet UITextField *firstNameField;
@property (weak,nonatomic) IBOutlet UITextField *lastNameField;
@property (weak,nonatomic) IBOutlet UITextField *voipNumberField;
@property (weak,nonatomic) NSString *identifierString;

-(void)updateViewUsing:(NSString *)identifier withFirstName:(NSString *)firstName withLastName:(NSString *)lastName withVoIPNumber:(NSString *)voipNumber;

@end
