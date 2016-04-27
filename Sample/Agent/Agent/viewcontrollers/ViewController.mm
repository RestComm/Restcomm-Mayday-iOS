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

#import "ViewController.h"
#import "RCManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [RCManager sharedInstance].serverURL=[defaults objectForKey:@"domainName"];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}
-(void)dismissKeyboard {
    [self.textName resignFirstResponder];
    [self.textPassword resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)doLogin:(id)sender
{
        if ([self.textName.text length]==0 || [self.textPassword.text length]==0) {
            [self showAlert:@"Username and Password cannot be blank."];
        }
        else if ([[RCManager sharedInstance].serverURL length]==0)
        {
            [self showAlert:@"Please configure Domain address in settings"];
        }
        else
        {
            [[RCManager sharedInstance] registerWithUserName:[NSString stringWithFormat:@"sip:%@@telestax.com", self.textName.text] password:self.textPassword.text];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnectivityUpdate:) name:RCReceiveConnectivityUpdate object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unregister:) name:UIApplicationWillResignActiveNotification object:nil];
        }
}
- (void) receiveConnectivityUpdate:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:RCReceiveConnectivityUpdate] integerValue]==1)
    {
        [self navigateToHome];
    }
    else
    {
        [self showAlert:@"Not a valid user."];
    }
}
- (void)navigateToHome {
    AgentOneViewController *homePage =
    [self.storyboard instantiateViewControllerWithIdentifier:@"AgentOneViewController"];
    [self presentViewController:homePage animated:YES completion:nil];
    
}
- (void)unregister:(NSNotification *)notification {
    [[RCManager sharedInstance]  disconnect];
}
-(void)showAlert:(NSString *)message
{
     [self dismissKeyboard];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(IBAction)settings:(id)sender
{
    [self dismissKeyboard];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Settings" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [av textFieldAtIndex:0].text=[defaults objectForKey:@"domainName"];
    
    // Alert style customization
    [[av textFieldAtIndex:0] setPlaceholder:@"Domain name eg:10.10.220.191:5060"];
    [av show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[alertView textFieldAtIndex:0].text containsString:@"5060"])
        {
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"domainName"];
        }
        else
        {
            [defaults setObject:[NSString stringWithFormat:@"%@:5060",[alertView textFieldAtIndex:0].text] forKey:@"domainName"];
        }
        [defaults synchronize];
        [RCManager sharedInstance].serverURL=[defaults objectForKey:@"domainName"];
    }
}
@end
