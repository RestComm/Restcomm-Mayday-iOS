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

#import "RCCustomChatAndVideoView.h"
#import "RCManager.h"
@implementation RCCustomChatAndVideoView
@synthesize buttonMinimizeOrMaximize,buttonSend,buttonMute;
+ (RCCustomChatAndVideoView*)sharedInstance
{
    // 1
    static RCCustomChatAndVideoView *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[RCCustomChatAndVideoView alloc] init];
    });
    return _sharedInstance;
}
+(id)customMessageViewFrame:(CGRect)frame
{
    RCCustomChatAndVideoView *customView = [[[NSBundle mainBundle] loadNibNamed:@"InstantMessageView" owner:nil options:nil] lastObject];
    [RCManager sharedInstance].isInstantMessagingInProgress=YES;
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[RCCustomChatAndVideoView class]])
    {
        customView.frame=frame;
        return customView;
    }
    else
        return nil;
}
+(id)customVideoViewFrame:(CGRect)frame :(BOOL)isClientVideoView
{
    RCCustomChatAndVideoView *customView = [[[NSBundle mainBundle] loadNibNamed:@"VideoChatView" owner:nil options:nil] lastObject];
    customView.isCustomer=isClientVideoView;
    [RCManager sharedInstance].isVideoChatInProgress=YES;
    [customView.activityindicator startAnimating];
    [customView.activityindicator setHidesWhenStopped:YES];
    if (isClientVideoView)
        customView.buttonReceive.hidden=YES;
    else
        customView.buttonReceive.hidden=NO;
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[RCCustomChatAndVideoView class]])
    {
        customView.frame=frame;
        return customView;
    }
    else
        return nil;
}
- (void)awakeFromNib
{
    [self addNSNotificationObservers];
    self.sipMessageText.delegate=self;
    [self addPanGesture];
}
-(void)addPanGesture
{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
}
- (void)pan:(UIPanGestureRecognizer *)aPan
{
    CGPoint currentPoint = [aPan locationInView:self.superview];
    if (currentPoint.y > 20 && currentPoint.y <self.superview.frame.size.height-180)
    {
        [UIView animateWithDuration:0.01f
                         animations:^{
                             NSLog(@"calling inside");
                             CGRect oldFrame = self.superview.frame;
                             if (![RCManager sharedInstance].isInstantMessagingInProgress)
                             {
                                 self.frame = CGRectMake(oldFrame.origin.x+30, currentPoint.y, oldFrame.size.width-60, ([UIScreen mainScreen].bounds.size.height - currentPoint.y));
                                 
                                 self.videoCallView= [[RCManager sharedInstance]  getVideoChatViewWithFrame:CGRectMake(0, 0, self.frame.size.width, ([UIScreen mainScreen].bounds.size.height - currentPoint.y -35))];
                                 
                                 [buttonMinimizeOrMaximize setBackgroundImage:[UIImage imageNamed:@"maximize.png"] forState:UIControlStateNormal];
                             }
                             else
                             {
                                 self.frame = CGRectMake(oldFrame.origin.x, currentPoint.y,oldFrame.size.width, ([UIScreen mainScreen].bounds.size.height - currentPoint.y));
                                 [buttonMinimizeOrMaximize setBackgroundImage:[UIImage imageNamed:@"chat_maximize.png"] forState:UIControlStateNormal];
                             }
                             
                             
                         }];
    }
}
-(void)addNSNotificationObservers
{
    //Adding notification observer to receive incoming message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appendNewMessageNotification:) name:RCIncomingMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVideoChatView) name:RCConnectionDidDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeActivityIndicator) name:RCRemoteVideoReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDeclined) name:RCConnectionConnectionDeclined object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeInstantMessageViewOnChatClosed) name:RCChatClosed object:nil];
}
-(RCCustomChatAndVideoView *)getRCCustomChatView:(CGRect)instantMessageFrame
{
    self.mChatView=[RCCustomChatAndVideoView customMessageViewFrame:instantMessageFrame];
    return self.mChatView;
}
-(RCCustomChatAndVideoView *)getRCCustomVideoChatView:(CGRect)videoChatViewFrame toEmbedInClientVideoView:(BOOL)embedInClientVideoView
{
    self.mChatView=[RCCustomChatAndVideoView customVideoViewFrame:videoChatViewFrame :embedInClientVideoView];
    [self.mChatView addSubview:[[RCManager sharedInstance]getVideoChatViewWithFrame:CGRectMake(0,0,self.mChatView.frame.size.width,self.mChatView.frame.size.height-35)]];
    return self.mChatView;
}
-(IBAction)receiveCall:(id)sender
{
    [[RCManager sharedInstance] answerVideoPressed];
    self.buttonReceive.hidden=YES;
}
/* --------- Instant messaging ---------*/
-(IBAction)sendMessage:(id)sender
{
    [self appendMessage:[NSString stringWithFormat:@"me:%@",self.sipMessageText.text]];
    // send an instant message using RCDevice
    [[RCManager sharedInstance]sendMessage:self.sipMessageText.text];
    self.sipMessageText.text = @"";
}
-(void)appendMessage:(NSString *)message
{
    [self.sipDialogText scrollRangeToVisible:self.sipDialogText.selectedRange];
    [self.sipDialogText setText:[NSString stringWithFormat:@"%@ %@\n\n",self.sipDialogText.text, message]];
}
-(NSString *)getUserName:(NSString *)sender
{
    NSString* schemaUsername = nil;
    NSString* username = nil;
    if ([sender rangeOfString:@"@"].location != NSNotFound)
    {
        schemaUsername = [sender componentsSeparatedByString:@"@"][0];
        if (schemaUsername && [schemaUsername rangeOfString:@":"].location != NSNotFound)
        {
            username = [schemaUsername componentsSeparatedByString:@":"][1];
        }
    }
    return username;
}
-(void)appendNewMessageNotification:(NSNotification*)notification
{
    [self appendMessage:[NSString stringWithFormat:@"%@:%@",[self getUserName:[notification.userInfo objectForKey:@"username"] ],[notification.userInfo objectForKey:@"message-text"]]];
    [RCManager sharedInstance].agentName=[self getUserName:[notification.userInfo objectForKey:@"username"]];
}
- (void)removeVideoChatView
{
    self.superview.frame = CGRectMake(0, 0,self.superview.frame.size.width,
                                      self.superview.frame.size.height);
    [RCManager sharedInstance].isVideoChatInProgress=NO;
    [self removeFromSuperview];
    [self removeNSNotifications];
    //Posting notification to enable may day
    [[NSNotificationCenter defaultCenter] postNotificationName:RCCancel object:self];
}
-(void)removeNSNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCIncomingMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCConnectionDidDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCRemoteVideoReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     RCConnectionConnectionDeclined object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCChatClosed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification
                                                  object:nil];
}
-(IBAction)removeRCCustomChatAndVideoView:(id)sender
{
    if ([RCManager sharedInstance].isInstantMessagingInProgress)
    {
        [RCManager sharedInstance].isInstantMessagingInProgress=NO;
        [self removeVideoChatView];
        [self instantMessagingDisabled];
    }
    else
    {
        [RCManager sharedInstance].isVideoChatInProgress=NO;
        if (self.isCustomer)
        {
            [[RCManager sharedInstance]disconnect];
        }
        else
        {
            if (![RCManager sharedInstance].remoteVideoTrack)
            {
                [[RCManager sharedInstance] diclineIncomingCall];
                [self removeVideoChatView];
            }
            else
            {
                [[RCManager sharedInstance]disconnect];
            }
        }
    }
}
-(void)connectionDeclined
{
    [self removeVideoChatView];
}
-(void)instantMessagingDisabled
{
    [[RCManager sharedInstance]sendMessage:RCChatClosed];
}
-(void)removeInstantMessageViewOnChatClosed
{
    if ([RCManager sharedInstance].isInstantMessagingInProgress)
    {
        [RCManager sharedInstance].isInstantMessagingInProgress=NO;
        [self removeVideoChatView];
    }
}
-(IBAction)minimizeOrMaximize:(id)sender
{
    if (self.frame.origin.y > 20)
    {
        self.frame = CGRectMake(0,20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-20);
        self.videoCallView= [[RCManager sharedInstance]  getVideoChatViewWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height-35)];
        [buttonMinimizeOrMaximize setBackgroundImage:[UIImage imageNamed:@"minimize.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height/2+100,[UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height/2-100);
        self.videoCallView= [[RCManager sharedInstance]  getVideoChatViewWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height-35)];
        [buttonMinimizeOrMaximize setBackgroundImage:[UIImage imageNamed:@"maximize.png"] forState:UIControlStateNormal];
    }
}
-(IBAction)minimizeOrMaximizeInstantMessageView:(id)sender
{
    if (self.frame.origin.y > 20)
    {
        self.frame = CGRectMake(0,20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-20);
        [buttonMinimizeOrMaximize setBackgroundImage:[UIImage imageNamed:@"chat_minimize.png"] forState:UIControlStateNormal];
        [self endEditing:YES];
    }
    else
    {
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
        [buttonMinimizeOrMaximize setBackgroundImage:[UIImage imageNamed:@"chat_maximize.png"] forState:UIControlStateNormal];
        [self endEditing:YES];
    }
}
-(IBAction)muteOrUnmute:(id)sender
{
    if (self.isMute) {
        [[RCManager sharedInstance]setMuted:true];
        [buttonMute setBackgroundImage:[UIImage imageNamed:@"speaker_mute.png"] forState:UIControlStateNormal];
        self.isMute=NO;
    }
    else
    {
        [[RCManager sharedInstance]setMuted:false];
        [buttonMute setBackgroundImage:[UIImage imageNamed:@"speaker_icon36.png"] forState:UIControlStateNormal];
        self.isMute=YES;
    }
}
-(void)removeActivityIndicator
{
    [self.activityindicator stopAnimating];
}
/* ----------Delegates for TextField---------- */
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [self endEditing:YES];
    return YES;
}
/* ----------Delegates for Keyboard---------- */
- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        self.superview.frame = CGRectMake(0, -kbSize.height, self.superview.frame.size.width, self.superview.frame.size.height);
    }];
}
-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.superview.frame = CGRectMake(0, 0,self.superview.frame.size.width, self.superview.frame.size.height);
    }];
    buttonMinimizeOrMaximize.hidden=NO;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}
@end