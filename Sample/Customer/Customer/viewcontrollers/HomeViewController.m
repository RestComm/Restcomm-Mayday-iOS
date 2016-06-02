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
#import "HomeViewController.h"
#import "RCManager.h"
#import "ARDVideoCallView.h"
@interface HomeViewController () {
    UIActivityIndicatorView *activityView;
}
@property (weak, nonatomic) IBOutlet UIButton *videoChatBtn;

@property ARDVideoCallView *videoCallView;
@property RCCustomChatAndVideoView *mChatView;
@end
@implementation HomeViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.toolbar setHidden:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableMayDay) name:RCCancel object:nil];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController.toolbar setHidden:YES];
    [self checkIfVideoChatOnGoing];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCCancel object:nil];
     [super viewDidDisappear:(BOOL)animated]; 
}
-(void)checkIfVideoChatOnGoing
{
    if ([[RCManager sharedInstance]isVideoChatInProgress] || [[RCManager sharedInstance]isInstantMessagingInProgress])
    {
        self.buttonMayDay.hidden=YES;
        [self.view addSubview:[RCCustomChatAndVideoView sharedInstance].mChatView];
    }
    else
    {
        self.buttonMayDay.hidden=NO;
    }
}
- (IBAction)videoChatBtnPressed:(id)sender
{
    [self showMayDayOptions];
}
-(void)showMayDayOptions
{
    self.buttonMayDay.hidden=YES;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:MAYDAY
                          message:@""
                          delegate:self // <== changed from nil to self
                          cancelButtonTitle:CANCEL
                          otherButtonTitles:IM,VIDEO, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        self.mChatView=[[RCCustomChatAndVideoView sharedInstance]getRCCustomChatView:CGRectMake(0, self.view.frame.size.height/2,self.view.frame.size.width,self.view.frame.size.height/2)];
        [self.view addSubview:self.mChatView];
    }
    else if(buttonIndex==2)
    {
        [[RCManager sharedInstance] connectToRC];
        //Pass YES to the parameter if customer else NO for Agent
        [self.view addSubview:[[RCCustomChatAndVideoView sharedInstance]getRCCustomVideoChatView:CGRectMake(30, self.view.frame.size.height/2+100,self.view.frame.size.width-60,self.view.frame.size.height/2-100) toEmbedInClientVideoView:YES]];
    }
    else
    {
        self.buttonMayDay.hidden=NO;
    }
}
-(void)enableMayDay
{
    self.buttonMayDay.hidden=NO;
}
@end