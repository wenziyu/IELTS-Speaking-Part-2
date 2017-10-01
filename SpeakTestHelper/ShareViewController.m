//
//  ShareViewController.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/10/1.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "ShareViewController.h"
#import <MessageUI/MessageUI.h>

@interface ShareViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)contactMePressed:(id)sender {
    [self sendMail];
}
- (IBAction)sharePressed:(id)sender {
    [self shareLineInfo];
}
-(void)shareLineInfo {
    NSString *textToShare = @"An App share to you -\nIELTS Speaking Part2";
    NSURL *myWebsite = [NSURL URLWithString:@"https://itunes.apple.com/tw/app/ielts-speaking-part-2/id1279615823?l=zh&mt=8"];
    
    NSArray *objectsToShare = [NSArray arrayWithObjects:textToShare, myWebsite, nil];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
-(void)sendMail {
    
    NSString *emailTitle = @"Comments for IELTS Speaking Part2";
    // Email Content
    NSString *messageBody = @"Please write down your comments.";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"zoedevelopertw@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
