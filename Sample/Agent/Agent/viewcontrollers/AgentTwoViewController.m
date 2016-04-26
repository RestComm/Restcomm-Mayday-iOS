/*
 * TeleStax, Open Source Cloud Communications
 * Copyright 2011-2016, Telestax Inc and individual contributors
 * by the @authors tag.
 *
 * This program is free software: you can redistribute it and/or modify
 * under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

#import "AgentTwoViewController.h"
#import "RCManager.h"
#import "ARDVideoCallView.h"
#import "AgentOneViewController.h"
@interface AgentTwoViewController ()
{
    BOOL mute;
    UIActivityIndicatorView *activityView;
    ARDVideoCallView *view;
}
@end
@implementation AgentTwoViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callDisconnected)
                                                 name:RCCancel
                                               object:nil];
    [self isInstantMessageEnabled];
    
}
-(void)isInstantMessageEnabled
{
    if ([RCManager sharedInstance].isInstantMessagingInProgress ||
        [RCManager sharedInstance].isVideoChatInProgress) {
        [self.view addSubview:self.mChatView];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)callDisconnected
{
    [self backHome];
}
- (IBAction)answerWithVideo:(id)sender
{
    
    [[RCManager sharedInstance] answerVideoPressed];
    [self.view addSubview:self.mChatView];
    [self.buttonReceive setHidden:YES];
}
-(void)backHome
{
    AgentOneViewController *homePage =
    [self.storyboard instantiateViewControllerWithIdentifier:@"AgentOneViewController"];
    [self presentViewController:homePage animated:YES completion:nil];
}
- (IBAction)endCall:(id)sender
{
    [[RCManager sharedInstance] diclineIncomingCall];
    [self backHome];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCCancel object:nil];
}
@end
