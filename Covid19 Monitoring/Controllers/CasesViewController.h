//
//  CasesViewController.h
//  Covid19 Monitoring
//
//  Created by Anthony Viriya on R 2/03/18.
//  Copyright © Reiwa 2 AVL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
NS_ASSUME_NONNULL_BEGIN

@interface CasesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UITableView *dataTable;

@property Database *db;
@end

NS_ASSUME_NONNULL_END
