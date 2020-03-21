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
    if(self.db.databases == nil){
        [self.loadingIndicator startAnimating];
        [self fetchingJSONData];
    }else{
        [self.loadingIndicator startAnimating];
        [self.loadingIndicator stopAnimating];
        self.loadingIndicator.hidesWhenStopped = YES;
        [self.dataTable reloadData];
    }
    
}

- (void) pullData:(NSURL*) url{
    self.db.databases  = [[NSMutableDictionary alloc] init];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        NSUserDefaults *localData = [NSUserDefaults standardUserDefaults];
        if (!error && statusCode == 200) {
           NSError * _Nullable err;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
            options:kNilOptions
              error:&err];
            for(NSDictionary *dd in json){
                NSDictionary *ddd = dd[@"attributes"];
                [self.db.databases setValue:ddd forKey:ddd[@"Country_Region"]];
            }
            self.db.dataArray = [self.db.databases allKeys];
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            self.db.dataArray = [self.db.dataArray sortedArrayUsingDescriptors:@[sort]];
            [localData setObject:self.db.databases forKey:@"databases"];
            [localData setObject:self.db.dataArray forKey:@"dataArray"];
            [localData synchronize];
        } else if([localData objectForKey:@"dataArray"]){
            self.db.dataArray =[localData objectForKey:@"dataArray"];
            self.db.databases = [localData objectForKey:@"databases"];
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIAlertController * alertvc = [UIAlertController alertControllerWithTitle: @ "Notification"
                                               message: @"Today's data isn't available right now, come back a few minutes again" preferredStyle: UIAlertControllerStyleAlert
                                              ];
                UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                          style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                            
                                          }
                                         ];
                [alertvc addAction: action];
                [self presentViewController: alertvc animated: true completion: nil];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
            self.loadingIndicator.hidesWhenStopped = YES;
            [self.dataTable reloadData];
        });
    }] resume];
}

- (void) fetchingJSONData{
    NSString *baseURL = @"https://api.kawalcorona.com";
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithString:baseURL]];
    [self pullData:url];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.db.databases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
 
    cell.textLabel.text = [self.db.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *country = [self.db.dataArray objectAtIndex:indexPath.row];
    NSDictionary *dataCountry = self.db.databases[country];
    NSString *msg = [NSString stringWithFormat:@"Confirmed: %@\nDeaths: %@\nRecovered: %@\nActive: %@\n", dataCountry[@"Confirmed"], dataCountry[@"Deaths"], dataCountry[@"Recovered"], dataCountry[@"Active"]];
    UIAlertController * alertvc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@ "Data for %@", country] message:msg preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                              style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                              }
                             ];
    [alertvc addAction: action];
    [self presentViewController: alertvc animated: true completion: nil];
}
@end
