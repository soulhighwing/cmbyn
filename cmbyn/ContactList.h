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
    NSMutableArray *allContactsArray; //Total Mobile Contacts from access from this variable
    NSMutableArray *voipContactsArray; //Contacts with voip
    NSMutableArray *groupsOfContact; //Collection of contacts by using contacts.framework
    CNContactStore *contactStore; //ContactStore Object
}

@property (nonatomic,retain) NSMutableArray *allContactsArray; //Total Mobile Contacts access from this variable property
@property (nonatomic,retain) NSMutableArray *voipContactsArray; //Total Mobile Contacts access from this variable property
//fetch Contact shared instance method
+(id)sharedContacts; //Singleton method

///fetch contacts from Addressbooks or Contacts framework
-(void)fetchAllContacts; //Method of fetch contacts from Addressbooks or Contacts framework
-(BOOL) addContact:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber; //METHOD for add a new contact
-(BOOL) updateExistContactBy:(NSString *)Identifier withFirst:(NSString *)firstName withLast:(NSString *)lastName withVoIP:(NSString *)voipNumber; //method for update a contact
-(BOOL) delContactBy:(NSString *)Identifier;//Method for del a contact

@end



