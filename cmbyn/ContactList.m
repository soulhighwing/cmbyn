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
//  AddressBook.framework and Contacts.framework will create a different type of arrays
//  Please use totalPhoneNumberArray for Contacts.framework one method and another method for AddressBook.framework to listout the contacts.

//  modified by haiying cao on 31/03/18
//  removed addressbook.framework support, fixed a bug in contacts.framework switch-case
//



#import "ContactList.h"

@implementation ContactList
@synthesize totalPhoneNumberArray;

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
        totalPhoneNumberArray = [NSMutableArray array]; //init a mutableArray
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
                    } else { // else ask to get a permission to access a contacts in this app.
                        [self getPermissionFromUser]; //Ask permission from user
                    }
                }];
            }
                break;
            case CNAuthorizationStatusAuthorized: { //Contact access permission is already authorized.
                [self fetchContactsFromContactsFrameWork]; //access contacts
            }
                break;
            default: { //else ask permission from user
                [self getPermissionFromUser];
            }
                break;
        }
        
    }
}

#pragma mark - Contacts.framework method
- (void)fetchContactsFromContactsFrameWork { //access contacts using contacts.framework
    
    NSArray *keyToFetch = @[CNContactEmailAddressesKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactPostalAddressesKey,CNContactThumbnailImageDataKey]; //contacts list key params to access using contacts.framework
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keyToFetch]; //Contacts fetch request parrams object allocation
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        [groupsOfContact addObject:contact]; //add objects of all contacts list in array
    }];
    
    NSMutableArray *phoneNumberArray = [@[] mutableCopy]; // init a mutable array
    
    NSDictionary *peopleDic; // create object
    
    //generate a custom dictionary to access
    for (CNContact *contact in groupsOfContact) {
        NSArray *thisOne = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
        //   [phoneNumberArray addObjectsFromArray:thisOne];
        //  NSLog(@"contact identifier: %@",contact.identifier);
        
        peopleDic = @{@"name":contact.givenName,
                      @"image":contact.thumbnailImageData != nil ? contact.thumbnailImageData:@"",
                      @"phone":thisOne,
                      @"selected":@"NO"
                      };
        
        [phoneNumberArray addObject:peopleDic]; //add object of people info to array
    }
    
    totalPhoneNumberArray = [phoneNumberArray mutableCopy]; //get a copy of all contacts list to array.
}

-(void)getPermissionFromUser {
//warning TODO: Show alert to the User, for enable the contacts permission in the Settings
    // The user has previously denied access
    // Send an alert telling user to change privacy setting in settings app
    NSLog(@"Get Permission from User");
}


@end
