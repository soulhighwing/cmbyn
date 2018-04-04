//
//  ContactList.h
//  ContactsList
//
//
//  Created by haiying cao on 31/03/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//
//  removed addressbook.framework support

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h> //Contacts.framework for above iOS 9
#import <UIKit/UIKit.h>
@interface ContactList : NSObject{
     CNContactStore *contactStore; //ContactStore Object
}

@property (nonatomic,retain) NSMutableArray *allContactsArray;//use for all contacts table view
@property (nonatomic,retain) NSMutableArray *voipContactsArray;//use for VoIP only contacts table view
@property (nonatomic,retain) NSMutableArray *historyArray;//use for history table view

+(id)sharedContacts; //Singleton method, Contact shared instance


-(void)fetchAllContacts; //Method of fetch contacts from Contacts framework

-(BOOL) addContact:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber; //METHOD for add a new contact
-(BOOL) updateExistContactBy:(NSString *)Identifier withFirst:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber; //method for update a contact

-(BOOL) delContactBy:(NSString *)Identifier;//Method for del a contact

-(void) delOneHistoryCall:(NSUInteger) index;//remove one history data

@end



