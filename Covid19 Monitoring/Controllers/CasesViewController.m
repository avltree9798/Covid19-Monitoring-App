//
//  CasesViewController.m
//  Covid19 Monitoring
//
//  Created by Anthony Viriya on R 2/03/18.
//  Copyright © Reiwa 2 AVL. All rights reserved.
//

#import "CasesViewController.h"

@interface CasesViewController ()

@end

@implementation CasesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.db = [Database getInstance];
    if(self.db.c == nil){
        [self.loadingIndicator startAnimating];
        [self fetchingJSONData];
    }else{
        [self.loadingIndicator startAnimating];
        NSLog(@"Data sudah ada");
        [self.loadingIndicator stopAnimating];
        self.loadingIndicator.hidesWhenStopped = YES;
        [self.dataTable reloadData];
    }
    
}

- (void) pullData:(NSURL*) url lastRequest:(BOOL) last{
    NSMutableDictionary *confirmed_cases = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *death_cases = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *recovered_cases = [[NSMutableDictionary alloc] init];
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (!error && statusCode == 200) {
            [[NSUserDefaults standardUserDefaults] setObject:[url absoluteString] forKey:@"url"];
            [[NSUserDefaults standardUserDefaults] synchronize];
           NSError * _Nullable err;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
            options:kNilOptions
              error:&err];
            for(NSDictionary *dd in json[@"items"]){
                if (![confirmed_cases objectForKey:dd[@"country_region"]]){
                    [countries addObject:dd[@"country_region"]];
                    [confirmed_cases setValue:[NSNumber numberWithInt:0] forKey:dd[@"country_region"]];
                    [death_cases setValue:[NSNumber numberWithInt:0] forKey:dd[@"country_region"]];
                    [recovered_cases setValue:[NSNumber numberWithInt:0] forKey:dd[@"country_region"]];
                }
                int confirmed = [confirmed_cases[dd[@"country_region"]] intValue] + [dd[@"confirmed"] intValue];
                int deaths = [death_cases[dd[@"country_region"]] intValue]+ [dd[@"deaths"] intValue];
                int recovered = [recovered_cases[dd[@"country_region"]] intValue]+ [dd[@"recovered"] intValue];
                confirmed_cases[dd[@"country_region"]]= [NSNumber numberWithInt:confirmed];
                death_cases[dd[@"country_region"]] = [NSNumber numberWithInt:deaths];
                recovered_cases[dd[@"country_region"]] = [NSNumber numberWithInt:recovered];
            }
            self.db.cc = confirmed_cases;
            self.db.dc = death_cases;
            self.db.rc = recovered_cases;
            NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            self.db.c = [countries sortedArrayUsingDescriptors:@[sd]];
        } else {
            NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
            if(!last && str){
                NSURL *url1 = [NSURL URLWithString:str];
                [self pullData:url1 lastRequest:YES];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIAlertController * alertvc = [UIAlertController alertControllerWithTitle: @ "Notification"
                                                   message: @"Today's data isn't available right now, come back a few minutes again" preferredStyle: UIAlertControllerStyleAlert
                                                  ];
                    UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                              style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                                NSLog(@ "Dismiss Tapped");
                                              }
                                             ];
                    [alertvc addAction: action];
                    [self presentViewController: alertvc animated: true completion: nil];
                });
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
            self.loadingIndicator.hidesWhenStopped = YES;
            [self.dataTable reloadData];
        });
    }] resume];
}

- (void) fetchingJSONData{
    NSString *baseURL = @"https://mq-covid-19-update.s3.ap-southeast-1.amazonaws.com";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/api/data/2020-03-18.json", baseURL, today]];
    [self pullData:url lastRequest:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.db.c count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
 
    cell.textLabel.text = [self.db.c objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *country = [self.db.c objectAtIndex:indexPath.row];
    NSString *msg = [NSString stringWithFormat:@"Confirmed: %@\nDeaths: %@\nRecovered: %@\n", self.db.cc[country], self.db.dc[country], self.db.rc[country]];
    UIAlertController * alertvc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@ "Data for %@", country] message:msg preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                              style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                NSLog(@ "Dismiss Tapped");
                              }
                             ];
    [alertvc addAction: action];
    [self presentViewController: alertvc animated: true completion: nil];
}
@end
