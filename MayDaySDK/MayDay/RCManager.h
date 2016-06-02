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

#import <Foundation/Foundation.h>
#import "RestCommClient.h"
#import "ARDVideoCallView.h"
#import "Constants.h"

static NSString *const RCInitialisationComplete =  @"RCInitialisationComplete";  //
static NSString *const RCRemoteVideoReceived =  @"RCRemoteVideoReceived";
static NSString *const RCIncomingCall =  @"RCIncomingCall";
static NSString *const RCIncomingMessage =  @"RCIncomingMessage";
static NSString *const RCConnectionDidDisconnect =  @"RCConnectionDidDisconnect";
static NSString *const RCConnectionConnectionDeclined =  @"RCConnectionConnectionDeclined";
static NSString *const RCChatClosed =  @"pYEDqOxOB35F7Pqp0QFwUNzAgCaiUBun";
static NSString *const RCCancel =  @"RCCancel";
static NSString *const RCReceiveConnectivityUpdate =  @"RCReceiveConnectivityUpdate";

@interface RCManager : NSObject<RCDeviceDelegate,RCConnectionDelegate>
@property BOOL isInitialized;
@property BOOL isRegistered;
@property BOOL isVideoChatInProgress;
@property BOOL isInstantMessagingInProgress;
@property NSString *serverURL;
@property NSString *agentName;
@property RTCVideoTrack *remoteVideoTrack;

+ (RCManager*)sharedInstance;
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password ;
- (void)disconnect;
- (void)connectToRC;
- (ARDVideoCallView *)getVideoChatViewWithFrame:(CGRect)videoFrame;
- (void)setMuted:(BOOL)muted;
-(void)sendMessage:(NSString *)message;
- (void)answerVideoPressed;
- (void)stopVideoRendering;
- (void)diclineIncomingCall;
@end
