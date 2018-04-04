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
@synthesize historyArray;

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
        allContactsArray =  [@[] mutableCopy];
        voipContactsArray = [@[] mutableCopy];
        historyArray = [@[] mutableCopy];
        //add observer for new call could place somewhere else
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addNewCall:)
                                                     name:@"newCalling"
                                                   object:nil];
        
        
    }
    return self;
}

#pragma mark - Fetch All Contacts from Addressbooks or Contacts framework
//Method of fetch contacts from Addressbooks or Contacts framework
- (void)fetchAllContacts {
    //we're going to renew all datas
    [allContactsArray removeAllObjects];
    [voipContactsArray removeAllObjects];
    [historyArray    removeAllObjects];
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
                        // post a message to let Main Interface know what happend so he can request for access
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsAccessDenied" object:nil];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsAccessDenied" object:nil];
                
            }
                break;
        }
        
    }
}

#pragma mark - Contacts.framework method
- (void)fetchContactsFromContactsFrameWork { //access contacts using contacts.framework
    
    NSArray *keyToFetch = @[CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey]; //contacts list key params to access using contacts.framework
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keyToFetch]; //Contacts fetch request parrams object allocation
    
    fetchRequest.sortOrder = CNContactSortOrderFamilyName;//order the contacts by family name
    
    NSMutableArray *   groupsOfContact = [@[] mutableCopy]; //arrary that save all the contacts we get
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        [groupsOfContact addObject:contact]; //add objects of all contacts list in array
    }];
    for (CNContact *contact in groupsOfContact) {
        NSMutableDictionary* personDict =[[self parseContact:contact] mutableCopy];
        [allContactsArray addObject:personDict];//add object of people into to array
        if([[personDict valueForKey:@"VoIPNumber"] isEqualToString:[NSString stringWithFormat:@""]]){
            //  NSLog(@"The voipnumber is empty");
        }
        else{
            //generate a custom dictionary to access voip only
            [voipContactsArray addObject:personDict];
        }
        //  NSLog(@"The allcontactsArray are - %@",allContactsArray);
        //  NSLog(@"The voipcontactsArray are - %@",voipContactsArray);
    }
    
    [self loadHistory];//load history data from standardUserDefaults
    [self updateHistoryInfo];//compare the history data with voip array so history data has the latest names
}
-(NSDictionary *)parseContact:(CNContact *)contact{//parse a CNContact into a NSDictionary
    NSString *phone;
    NSString *fullName;
    NSString *firstName;
    NSString *lastName;
    UIImage *profileImage;
    
    firstName = contact.givenName;
    lastName = contact.familyName;
    //prase and format fullname
    if (lastName == nil) {
        fullName=[NSString stringWithFormat:@"%@",firstName];
    }else if (firstName == nil){
        fullName=[NSString stringWithFormat:@"%@",lastName];
    }
    else{
        fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
    }
    
    //profileImage from thumbnail
    if (contact.thumbnailImageData != nil) {
        profileImage = [UIImage imageWithData:contact.thumbnailImageData];
    }else{
        //if no thumbnail image put an unknow.jpg instead
        profileImage = [UIImage imageNamed:@"unknow.jpg"];
    }
    //get the VoIP number from contact.phoneNumbers
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
//add a contact to contacts and add related info to related arraries
-(BOOL) addContact:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber{
    CNMutableContact *contactTobeAdd = [[CNMutableContact alloc] init];
    //name
    contactTobeAdd.givenName = firstName!=nil? firstName:[NSString stringWithFormat:@""];
    contactTobeAdd.familyName = lastName!=nil? lastName:[NSString stringWithFormat:@""];
    //voip number
    CNPhoneNumber * phone =[CNPhoneNumber phoneNumberWithStringValue:voipNumber];
    
    contactTobeAdd.phoneNumbers = [[NSArray alloc] initWithObjects:[CNLabeledValue labeledValueWithLabel:@"VoIP" value:phone], nil];
    //request
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    //save
    [saveRequest addContact:contactTobeAdd toContainerWithIdentifier:contactStore.defaultContainerIdentifier];
    
    NSError *error;
    if([contactStore executeSaveRequest:saveRequest error:&error]) {
        //if Contacts added
        //add new contact and sorting the all three arraries for tableviews
        [self addContactToArray:contactTobeAdd];
        [self sortingArray];
        [self updateHistoryInfo];
        NSLog(@"add complete");
        return YES;
    }else {
        NSLog(@"add contact error : %@", [error description]);
        return NO;
    }
}

//modify a contact by it's identifier
-(BOOL) updateExistContactBy:(NSString *)Identifier withFirst:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber{
    //get contact from contacts first
    NSArray *keyToFetch = @[CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
    CNContact *contact =[contactStore unifiedContactWithIdentifier:Identifier keysToFetch:keyToFetch error:nil];
    //modify info
    CNMutableContact *contactTobeUpdate = contact.mutableCopy;
    //name
    contactTobeUpdate.givenName = firstName!=nil? firstName:[NSString stringWithFormat:@""];
    contactTobeUpdate.familyName = lastName!=nil? lastName:[NSString stringWithFormat:@""];
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
    //phoneNumbers ready
    contactTobeUpdate.phoneNumbers = phoneNumbersTobeUpdate;
    
    //start saving to contacts
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:contactTobeUpdate];
    
    NSError *error;
    if([contactStore executeSaveRequest:saveRequest error:&error]) {
        //remove old contact by identifier,then add new contact and sorting all three arries for table view
        [self removeContactFromArrayBy:Identifier];
        [self addContactToArray:contactTobeUpdate];
        [self sortingArray];
        [self updateHistoryInfo];
        
        NSLog(@"update complete");
        return YES;
    }else {
        NSLog(@"update contact error : %@", [error description]);
        return NO;
    }
}

//delete a contact by it's identifer
-(BOOL) delContactBy:(NSString *)Identifier{
    NSArray *keyToFetch = @[CNContactFamilyNameKey];//actually we don't need fetch any keys other than identifier
    CNContact *contact =[contactStore unifiedContactWithIdentifier:Identifier keysToFetch:keyToFetch error:nil];//fetch the contact
    CNMutableContact *mutableContact = contact.mutableCopy;
    //delete processing
    CNSaveRequest *deleteRequest = [[CNSaveRequest alloc] init];
    [deleteRequest deleteContact:mutableContact];
    
    NSError *error;
    if([contactStore executeSaveRequest:deleteRequest error:&error]) {
        //if contact data has deleted we can remove the data from our arraies
        [self removeContactFromArrayBy:Identifier];
        [self updateHistoryInfo];
        NSLog(@"delete complete");
        return YES;
    }else {
        NSLog(@"delete error : %@", [error description]);
    }    return NO;
}


#pragma mark Array Operate
//add a contact to both contacts arraies
-(void) addContactToArray:(CNMutableContact *)contact{
    NSDictionary *newPerson= [self parseContact:contact];
    [allContactsArray addObject:newPerson];
    if([[newPerson valueForKey:@"VoIPNumber"]  isEqualToString:[NSString stringWithFormat:@""]]){
        
    }
    else{
        [voipContactsArray addObject:newPerson];
    }
    
}

//remove contact from both contacts arraies
- (void) removeContactFromArrayBy:(NSString *)Identifier{
    //find index for identifier in both arraies
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
    //remove them
    if(indexInAll != NSNotFound){
        [allContactsArray removeObjectAtIndex:indexInAll];
    }
    if(indexInVoIP != NSNotFound){
        [voipContactsArray removeObjectAtIndex:indexInVoIP];
    }
}
//sorting both arraies by last name
- (void) sortingArray{
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [allContactsArray sortUsingDescriptors:[NSArray arrayWithObject:sortName]];
    [voipContactsArray sortUsingDescriptors:[NSArray arrayWithObject:sortName]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContacts" object:self];
    
}

#pragma mark historyArray
// when we get a new call, add it to calling history array
- (void) addNewCall:(NSNotification *) notification {
    //need a time info
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    
    NSMutableDictionary *toBeAdd = [notification.userInfo mutableCopy];
    [toBeAdd setObject:dateString forKey:@"callTime"];
    [historyArray insertObject:toBeAdd atIndex:0]; //new call always on the top of the array
    [self saveHistory];//save array to standardUserDefaults
}

// remove a history call from array and save the array to aply the change
-(void) delOneHistoryCall:(NSUInteger) index{
    [historyArray removeObjectAtIndex:index];
    [self saveHistory];//save array to standardUserDefaults
}

//save the history array to standardUserDefaults
-(void) saveHistory{
    //we only need to save the number and time of calls
    NSMutableArray *archiveArray =[@[] mutableCopy];
    for (NSDictionary *oneCall in historyArray) {
        NSDictionary *toBeSave = @{@"VoIPNumber":[oneCall objectForKey:@"VoIPNumber"],
                                   @"callTime":[oneCall objectForKey:@"callTime"]
                                   };
        NSData *oneEncodedCall = [NSKeyedArchiver archivedDataWithRootObject:toBeSave];//archive the data
        [archiveArray addObject:oneEncodedCall];
    }
    //save it
    [[NSUserDefaults standardUserDefaults] setObject:archiveArray forKey:@"historyCalls"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//read the history array from standardUserDefaults
-(void) loadHistory{
    NSMutableArray *archiveArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"historyCalls"] mutableCopy];
    for (NSData *toBeGet in archiveArray) {
        NSDictionary *toBeSave = [NSKeyedUnarchiver unarchiveObjectWithData:toBeGet];
        [historyArray addObject:toBeSave];
    }
}

//compare the history array with voip array
-(void)updateHistoryInfo{
    //compare the voip number with history call and add extra info to historyArray
    int i;
    NSUInteger count=historyArray.count;
    for (i = 0; i < count; i++){
        NSUInteger indexInHistory = [voipContactsArray indexOfObjectPassingTest:
                                     ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                                     {
                                         //compare only voip number if there's duplicated number always use the first contact
                                         return [[dict objectForKey:@"VoIPNumber"] isEqualToString:[historyArray[i] valueForKey:@"VoIPNumber"]];
                                     }
                                     ];
        if(indexInHistory != NSNotFound){
            //if found we put the extra info it into the history array merge two dictionary
            NSMutableDictionary *personDict= [historyArray[i] mutableCopy];
            [personDict addEntriesFromDictionary:voipContactsArray[indexInHistory]];
            [historyArray replaceObjectAtIndex:i withObject:personDict];
        }
        else{
            //if not found we have a new call number remove all other info left only number and time
            //     NSMutableDictionary *personDict= [historyArray[i] mutableCopy];
            //    [personDict addEntriesFromDictionary:voipContactsArray[indexInHistory]];
            
            NSDictionary* personDict = @{@"fullName":@"",
                                         @"firstName":@"",
                                         @"lastName":@"",
                                         @"userImage":[UIImage imageNamed:@"unknow.jpg"],
                                         @"VoIPNumber":[historyArray[i] objectForKey:@"VoIPNumber"],
                                         @"callTime":[historyArray[i] objectForKey:@"callTime"]
                                         };
            
            [historyArray replaceObjectAtIndex:i withObject:personDict];
        }
        
    }
    //post message to let historyview reload data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHistory" object:nil];
    
    
}

@end
