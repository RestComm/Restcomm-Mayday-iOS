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

#import "AgentOneViewController.h"

@interface AgentOneViewController ()
@property RCCustomChatAndVideoView *mChatView;
@end

@implementation AgentOneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incomingCall:)
                                                 name:RCIncomingCall
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incomingMessage:)
                                                 name:RCIncomingMessage
                                               object:nil];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) incomingCall:(NSNotification *) notification
{
    AgentTwoViewController *homePage =
    [self.storyboard instantiateViewControllerWithIdentifier:@"AgentTwoViewController"];
    homePage.mChatView=[[RCCustomChatAndVideoView sharedInstance]getRCCustomVideoChatView:
    CGRectMake(30, self.view.frame.size.height/2+100,self.view.frame.size.width-60,self.view.frame.size.height/2-100)  toEmbedInClientVideoView:NO];
    [self presentViewController:homePage animated:YES completion:nil];
}
-(void)incomingMessage:(NSNotification *) notification
{
    AgentTwoViewController *homePage =
    [self.storyboard instantiateViewControllerWithIdentifier:@"AgentTwoViewController"];
    [RCManager sharedInstance].isInstantMessagingInProgress=YES;
    homePage.mChatView=[[RCCustomChatAndVideoView sharedInstance]getRCCustomChatView:CGRectMake(0, self.view.frame.size.height/2,self.view.frame.size.width,self.view.frame.size.height/2)];
    [homePage.mChatView appendNewMessageNotification:notification];
    [self presentViewController:homePage animated:YES completion:nil];
}
-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"calling view did disappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCIncomingMessage object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:RCIncomingCall object:nil];
}
@end
