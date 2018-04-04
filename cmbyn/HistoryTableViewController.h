//
//  HistoryTableViewController.h
//  cmbyn
//
//  Created by haiying cao on 4/04/18.
//  Copyright © 2018 Highwing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "editContactViewController.h"

@interface HistoryTableViewController : UITableViewController{
    NSMutableArray *historyArray;
    editContactViewController *editController;
}

@end
