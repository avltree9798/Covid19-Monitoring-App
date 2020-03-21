//
//  Database.h
//  Covid19 Monitoring
//
//  Created by Anthony Viriya on R 2/03/19.
//  Copyright © Reiwa 2 AVL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Database : NSObject
@property  NSMutableDictionary *databases;
@property NSArray* dataArray;
+(Database*) getInstance;
@end

NS_ASSUME_NONNULL_END
