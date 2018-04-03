//
//  ContactList.m
//  ContactsList
//
//
//  Created by haiying cao on 31/03/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//
// The main idea is to maintain two NSMutableArray instead of repeadly get contacts
// that shall make app faster when the contact list is long

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
    
     if (NSClassFromString(@"CNContactStore")) { //if Contacts.framework is available
        contactStore = [[CNContactStore alloc] init]; //init a contactStore object
        
        //Check contacts authorization status using Contacts.framework entity
        switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
                
            case CNAuthorizationStatusNotDetermined: { //Address book status not determined.
                
                [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
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
    
    fetchRequest.sortOrder = CNContactSortOrderFamilyName;//order the contacts by user default
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        [groupsOfContact addObject:contact]; //add objects of all contacts list in array
    }];
    //generate a custom dictionary to access
    for (CNContact *contact in groupsOfContact) {
        NSDictionary* personDict =[self parseContact:contact];
        [allContactsArray addObject:personDict];//add object of people into to array
        if([[personDict valueForKey:@"VoIPNumber"] isEqualToString:[NSString stringWithFormat:@""]]){
            NSLog(@"The voipnumber is empty");
        }
        else{
            [voipContactsArray addObject:personDict];
        }
        //  NSLog(@"The allcontactsArray are - %@",allContactsArray);
      //  NSLog(@"The voipcontactsArray are - %@",voipContactsArray);
    }
}
-(NSDictionary *)parseContact:(CNContact *)contact{
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
    return personDict;
}
-(void)getPermissionFromUser {
//warning TODO: Show alert to the User, for enable the contacts permission in the Settings
    // The user has previously denied access
    // Send an alert telling user to change privacy setting in settings app
    NSLog(@"Get Permission from User");
}

-(BOOL) addContact:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber{
    CNMutableContact *contactTobeAdd = [[CNMutableContact alloc] init];
    
    contactTobeAdd.givenName = firstName;
    contactTobeAdd.familyName = lastName;
    CNPhoneNumber * phone =[CNPhoneNumber phoneNumberWithStringValue:voipNumber];
    
    contactTobeAdd.phoneNumbers = [[NSArray alloc] initWithObjects:[CNLabeledValue labeledValueWithLabel:@"VoIP" value:phone], nil];
  
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:contactTobeAdd toContainerWithIdentifier:contactStore.defaultContainerIdentifier];
    
    NSError *error;
    if([contactStore executeSaveRequest:saveRequest error:&error]) {
        //add new contact and sorting
        [self addContactToArray:contactTobeAdd];
        [self sortingArray];
        NSLog(@"add complete");
        return YES;
     }else {
        NSLog(@"add contact error : %@", [error description]);
        return NO;
    }
}

-(BOOL) updateExistContactBy:(NSString *)Identifier withFirst:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber{
     NSArray *keyToFetch = @[CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
    CNContact *contact =[contactStore unifiedContactWithIdentifier:Identifier keysToFetch:keyToFetch error:nil];
    CNMutableContact *contactTobeUpdate = contact.mutableCopy;
    contactTobeUpdate.givenName = firstName;
    contactTobeUpdate.familyName = lastName;
    //we need to extract all the phone numbers from contact and find the voip label
    //if no voip label we need add one, if find replace it with the new number
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
    
    //start saving to contacts
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:contactTobeUpdate];
    
    NSError *error;
    if([contactStore executeSaveRequest:saveRequest error:&error]) {
        //remove old contact by identifier add new contact and sorting
        [self removeContactFromArrayBy:Identifier];
        [self addContactToArray:contactTobeUpdate];
        [self sortingArray];

        NSLog(@"update complete");
        return YES;
    }else {
        NSLog(@"update contact error : %@", [error description]);
        return NO;
    }
}

-(BOOL) delContactBy:(NSString *)Identifier{
    NSArray *keyToFetch = @[CNContactFamilyNameKey];//we don't need fetch any keys other than identifier
    CNContact *contact =[contactStore unifiedContactWithIdentifier:Identifier keysToFetch:keyToFetch error:nil];
    CNMutableContact *mutableContact = contact.mutableCopy;
    CNSaveRequest *deleteRequest = [[CNSaveRequest alloc] init];
    [deleteRequest deleteContact:mutableContact];
    
    NSError *error;
    if([contactStore executeSaveRequest:deleteRequest error:&error]) {
        [self removeContactFromArrayBy:Identifier];
        NSLog(@"delete complete");
          return YES;
    }else {
        NSLog(@"delete error : %@", [error description]);
    }    return NO;
}

-(void) addContactToArray:(CNMutableContact *)contact{
    NSDictionary *newPerson= [self parseContact:contact];
    [allContactsArray addObject:newPerson];
    if([[newPerson valueForKey:@"VoIPNumber"]  isEqualToString:[NSString stringWithFormat:@""]]){
        
    }
    else{
        [voipContactsArray addObject:newPerson];
    }

}

- (void) removeContactFromArrayBy:(NSString *)Identifier{
    //if contact data is deleted we can remove the data from our array
    NSUInteger indexInAll = [allContactsArray indexOfObjectPassingTest:
                             ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                             {
                                 return [[dict objectForKey:@"ID"] isEqual:Identifier];
                             }
                             ];
    NSUInteger indexInVoIP = [voipContactsArray indexOfObjectPassingTest:
                              ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                              {
                                  return [[dict objectForKey:@"ID"] isEqual:Identifier];
                              }
                              ];
    if(indexInAll != NSNotFound){
        [allContactsArray removeObjectAtIndex:indexInAll];
    }
    if(indexInVoIP != NSNotFound){
        [voipContactsArray removeObjectAtIndex:indexInVoIP];
    }
}
- (void) sortingArray{
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [allContactsArray sortUsingDescriptors:[NSArray arrayWithObject:sortName]];
    [voipContactsArray sortUsingDescriptors:[NSArray arrayWithObject:sortName]];
 }

@end
