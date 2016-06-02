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

#import <UIKit/UIKit.h>
#import "ARDVideoCallView.h"
@interface RCCustomChatAndVideoView : UIView<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonMinimizeOrMaximize;
@property (weak, nonatomic) IBOutlet UIButton *buttonSend;
@property (weak, nonatomic) IBOutlet UIButton *buttonMute;
@property (weak, nonatomic) IBOutlet UIButton *buttonReceive;
@property (weak, nonatomic) IBOutlet UITextView *sipDialogText;
@property (weak, nonatomic) IBOutlet UITextField *sipMessageText;
@property ARDVideoCallView *videoCallView;
@property BOOL isMute;
@property BOOL isCustomer;
@property RCCustomChatAndVideoView *mChatView;
+ (RCCustomChatAndVideoView*)sharedInstance;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityindicator;
+(id)customMessageViewFrame:(CGRect)frame;
+(id)customVideoViewFrame:(CGRect)frame :(BOOL)isClientVideoView;
-(void)appendNewMessageNotification:(NSNotification*)notification;
-(RCCustomChatAndVideoView *)getRCCustomChatView:(CGRect)instantMessageFrame;
-(RCCustomChatAndVideoView *)getRCCustomVideoChatView:(CGRect)videoChatViewFrame toEmbedInClientVideoView:(BOOL)embedInClientVideoView;
@end