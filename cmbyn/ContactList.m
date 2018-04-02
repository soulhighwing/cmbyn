//
//  ContactList.m
//  ContactsList
//
//  Created by ndot on 11/01/16.
//  Copyright © 2016 Ktr. All rights reserved.
//
//  My blog address: https://ktrkathir.wordpress.com
//
//  Fetch all contacts using both AddressBook.framework and Contacts.framework
//
//
//  This class file will help you to access contacts app persons details.

//  modified by haiying cao on 31/03/18
//  removed addressbook.framework support, fixed a bug in contacts.framework switch-case
//



#import "ContactList.h"

@implementation ContactList
@synthesize allContactsArray;
@synthesize voipContactsArray;

#pragma mark - Singleton Methods
+ (id)sharedContacts { //Shared instance method
    
    static ContactList *sharedMyContacts = nil; //create contactsList Object
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ //for first time create shared instance object
        sharedMyContacts = [[self alloc] init];
    });
    
    return sharedMyContacts;
}

- (id)init { //init method
    if (self = [super init]) {
        allContactsArray = [NSMutableArray array]; //init a mutableArray
        voipContactsArray = [NSMutableArray array]; //init
    }
    return self;
}

#pragma mark - Fetch All Contacts from Addressbooks or Contacts framework
//Method of fetch contacts from Addressbooks or Contacts framework
- (void)fetchAllContacts {
    
    groupsOfContact = [@[] mutableCopy]; //init a mutable array
    
    //In iOS 9 and above, use Contacts.framework
    if (NSClassFromString(@"CNContactStore")) { //if Contacts.framework is available
        contactStore = [[CNContactStore alloc] init]; //init a contactStore object
        
        //Check contacts authorization status using Contacts.framework entity
        switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
                
            case CNAuthorizationStatusNotDetermined: { //Address book status not determined.
                
                [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) { //permission Request alert will show here.
                    if (granted) { //if user allow to access a contacts in this app.
                        [self fetchContactsFromContactsFrameWork]; //access contacts
                    } else {
                        // The user has denied access
                        [self getPermissionFromUser]; //Ask permission from user
                    }
                }];
            }
                break;
            case CNAuthorizationStatusAuthorized: { //Contact access permission is already authorized.
                [self fetchContactsFromContactsFrameWork]; //access contacts
            }
                break;
            default: {
                // The user has previously denied access
                // Send an alert telling user to change privacy setting in settings app
                [self getPermissionFromUser];
            }
                break;
        }
        
    }
}

#pragma mark - Contacts.framework method
- (void)fetchContactsFromContactsFrameWork { //access contacts using contacts.framework
    
    NSArray *keyToFetch = @[CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey]; //contacts list key params to access using contacts.framework
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keyToFetch]; //Contacts fetch request parrams object allocation
    
    fetchRequest.sortOrder = CNContactSortOrderUserDefault;//order the contacts by user default
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        [groupsOfContact addObject:contact]; //add objects of all contacts list in array
    }];
    
    
    NSMutableArray *allArray = [@[] mutableCopy]; // init a mutable array
    NSMutableArray *voipArray = [@[] mutableCopy]; // init a mutable array

    
    //generate a custom dictionary to access
    for (CNContact *contact in groupsOfContact) {
        NSString *phone;
        NSString *fullName;
        NSString *firstName;
        NSString *lastName;
        UIImage *profileImage;
 
        firstName = contact.givenName;
        lastName = contact.familyName;
        if (lastName == nil) {
            fullName=[NSString stringWithFormat:@"%@",firstName];
        }else if (firstName == nil){
            fullName=[NSString stringWithFormat:@"%@",lastName];
        }
        else{
            fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
        }
        

        if (contact.thumbnailImageData != nil) {
            profileImage = [UIImage imageWithData:contact.thumbnailImageData];
        }else{
            profileImage = [UIImage imageNamed:@"244.jpg"];
        }
        phone = [NSString stringWithFormat:@""];
        for (CNLabeledValue *label in contact.phoneNumbers) {
            if([label.label isEqualToString:[NSString stringWithFormat:@"VoIP"]]){
                phone = [label.value stringValue];
            }
        }
       
        
        NSDictionary* personDict = @{@"fullName":fullName,
                                     @"firstName":firstName,
                                     @"lastName":lastName,
                      @"userImage":profileImage,
                      @"VoIPNumber":phone,
                      @"ID": contact.identifier
                      };
        
        
        
        [allArray addObject:personDict];//add object of people into to array
        NSLog(@"The allcontactsArray are - %@",allArray);
        if([phone isEqualToString:[NSString stringWithFormat:@""]]){
            
        }
        else{
            [voipArray addObject:personDict];
        }
        NSLog(@"The voipcontactsArray are - %@",voipArray);
    }
    
    allContactsArray = [allArray mutableCopy]; //get a copy of all contacts list to array.
    voipContactsArray = [voipArray mutableCopy]; //get a copy of voip contacts list to array.

    /*
    NSArray *sorted=[allContactsArray sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc]initWithKey:@"fullName" ascending:YES]]];
    NSLog(@"%@",sorted);*/

}

-(void)getPermissionFromUser {
//warning TODO: Show alert to the User, for enable the contacts permission in the Settings
    // The user has previously denied access
    // Send an alert telling user to change privacy setting in settings app
    NSLog(@"Get Permission from User");
}

-(BOOL) addContact:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber{
    CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
    
    mutableContact.givenName = firstName;
    mutableContact.familyName = lastName;
    CNPhoneNumber * phone =[CNPhoneNumber phoneNumberWithStringValue:voipNumber];
    
    mutableContact.phoneNumbers = [[NSArray alloc] initWithObjects:[CNLabeledValue labeledValueWithLabel:@"VoIP" value:phone], nil];
  
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:mutableContact toContainerWithIdentifier:contactStore.defaultContainerIdentifier];
    
    NSError *error;
    if([contactStore executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
        return YES;
     }else {
        NSLog(@"save error");
    }
    return NO;
}

-(BOOL) updateExistContactBy:(NSString *)Identifier withFirst:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber{
     NSArray *keyToFetch = @[CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
    CNContact *contact =[contactStore unifiedContactWithIdentifier:Identifier keysToFetch:keyToFetch error:nil];
    CNMutableContact *contactTobeUpdate = contact.mutableCopy;
    contactTobeUpdate.givenName = firstName;
    contactTobeUpdate.familyName = lastName;
    NSMutableArray *phoneNumbersTobeUpdate =[@[] mutableCopy];
    BOOL foundVoIP = NO;
    
    for (CNLabeledValue *label in contactTobeUpdate.phoneNumbers) {
   
        if([label.label isEqualToString:[NSString stringWithFormat:@"VoIP"]]){
            //if we found voip label we update it
            CNPhoneNumber *voipPhoneNumber = [[CNPhoneNumber alloc] initWithStringValue:voipNumber];
            CNLabeledValue *labelTobeUpdate = [[CNLabeledValue alloc] initWithLabel:label.label value:voipPhoneNumber];
            [phoneNumbersTobeUpdate addObject:labelTobeUpdate];
            foundVoIP = YES;
        }
        else{
            //if it's not a voip label, we simply copy it
            [phoneNumbersTobeUpdate addObject:label];
        }
    }
    if(!foundVoIP){
        //if we can't find voip label , we creat one and append it
        CNPhoneNumber *voipPhoneNumber = [[CNPhoneNumber alloc] initWithStringValue:voipNumber];
        CNLabeledValue *labelTobeUpdate = [CNLabeledValue labeledValueWithLabel:@"VoIP" value:voipPhoneNumber];
            [phoneNumbersTobeUpdate addObject:labelTobeUpdate];
    }
    contactTobeUpdate.phoneNumbers = phoneNumbersTobeUpdate;
    

    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:contactTobeUpdate];
    
    NSError *error;
    if([contactStore executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
        return YES;
    }else {
        NSLog(@"save error : %@", [error description]);
    }
    return NO;
}


@end
