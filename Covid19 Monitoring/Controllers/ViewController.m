//
//  ViewController.m
//  Covid19 Monitoring
//
//  Created by Anthony Viriya on R 2/03/18.
//  Copyright © Reiwa 2 AVL. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(IBAction)unwindToHome:(UIStoryboardSegue *)sender{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)exitButtonClicked:(id)sender {
    exit(0);
}

@end
