//
//  Database.m
//  Covid19 Monitoring
//
//  Created by Anthony Viriya on R 2/03/19.
//  Copyright © Reiwa 2 AVL. All rights reserved.
//

#import "Database.h"

@implementation Database
static Database *sharedInstance = nil;
+ (Database *) getInstance{
    if(!sharedInstance){
        sharedInstance = [[Database alloc] init];
    }
    return sharedInstance;
}
@end
