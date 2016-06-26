#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <PassKit/PassKit.h>

@interface CDVApplePay : CDVPlugin
<
PKPaymentAuthorizationViewControllerDelegate
>
{
    NSString *merchantId;
    NSString *stripePublishableKey;
    NSString *callbackId;
}

- (void)setupStripe:(CDVInvokedUrlCommand*)command;
- (void)getAllowsApplePay:(CDVInvokedUrlCommand*)command;
- (void)getStripeToken:(CDVInvokedUrlCommand*)command;

@end
