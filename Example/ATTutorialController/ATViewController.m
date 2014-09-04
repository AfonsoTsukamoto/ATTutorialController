//
//  ATViewController.m
//  ATTutorialController
//
//  Created by Afonso Tsukamoto on 09/04/2014.
//  Copyright (c) 2014 Afonso Tsukamoto. All rights reserved.
//

#import "ATViewController.h"
#import <ATTutorialController/ATTutorialController.h>

@interface ATViewController ()
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation ATViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    // Just a trick to get the nav bar items
    NSMutableArray* buttons = [[NSMutableArray alloc] init];
    for (UIControl* btn in self.navBar.subviews){
        if ([btn isKindOfClass:[UIControl class]])
            [buttons addObject:btn];
    }
    // And then sort them, just to be sure
    NSArray *sortedButtons = [buttons sortedArrayUsingComparator:^NSComparisonResult(UIControl *obj1, UIControl *obj2) {
        if(obj1.frame.origin.x < obj2.frame.origin.x){
            return NSOrderedAscending;
        }else if(obj1.frame.origin.x > obj2.frame.origin.x){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    [[ATTutorialController sharedInstance] showTutorialWithFramesAndStringsBlock:^NSArray *{
        UIView *leftButton =((UIView *)sortedButtons[0]);
        UIView *rightButton =((UIView *)sortedButtons[1]);
        
        CGRect frame1 = [self.navBar convertRect:leftButton.frame toView:nil];
        CGRect frame3 = [self.navBar convertRect:rightButton.frame toView:nil];
        
        return @[
                 @{@"frame": [NSValue valueWithCGRect:frame1], @"string": @"A beautiful item 1" },
                 @{@"frame": [NSValue valueWithCGRect:frame3], @"string": @"A beautiful item 2" }
                 ];
    } completion:^{
        // Some completion code
        [self.tableView setContentOffset:(CGPoint) { self.tableView.contentOffset.x, self.tableView.contentSize.height-self.tableView.frame.size.height }
                                animated:YES];
    } waitsForTouch:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDDS

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"Cell %d", indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
