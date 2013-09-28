//
//  RFViewController.m
//  PhotoEditor
//
//  Created by Darshan Katrumane on 9/27/13.
//  Copyright (c) 2013 Darshan Katrumane. All rights reserved.
//

#import "RFViewController.h"
#import "RDPhotoEditor.h"

@interface RFViewController ()

@end

@implementation RFViewController

-(void) loadPhotoEditor {
    RDPhotoEditor *editor = [[RDPhotoEditor alloc] init];
    [editor setOriginalPhoto:[UIImage imageNamed:@"flower.jpeg"]];
    [self presentViewController:editor animated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [self loadPhotoEditor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
