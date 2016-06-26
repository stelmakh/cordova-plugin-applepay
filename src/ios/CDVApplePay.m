#import "CDVApplePay.h"
#import <PassKit/PassKit.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Stripe/Stripe+ApplePay.h>

@implementation CDVApplePay

- (void)dealloc
{

}

- (void)onReset
{

}

- (void)setupStripe:(CDVInvokedUrlCommand*)command
{
    merchantId = [command.arguments objectAtIndex:0];
    stripePublishableKey = [command.arguments objectAtIndex:1];
    [Stripe setDefaultPublishableKey: stripePublishableKey];
    NSLog(@"ApplePay set merchant id to %@", merchantId);
    NSLog(@"ApplePay set stripe publishable key to %@", stripePublishableKey);
}

- (void)getAllowsApplePay:(CDVInvokedUrlCommand*)command
{
    if (merchantId == nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Please call setupStripe() with your Apple-given merchant ID."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:merchantId];

    // Configure a dummy request
    NSString *label = @"Premium Llama Food";
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
    request.paymentSummaryItems = @[
                                    [PKPaymentSummaryItem summaryItemWithLabel:label
                                                                        amount:amount]
                                    ];

    if ([Stripe canSubmitPaymentRequest:request]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"user has apple pay"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"user does not have apple pay"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)getStripeToken:(CDVInvokedUrlCommand*)command
{

    if (merchantId == nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Please call setupStripe() with your Apple-given merchant ID."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    PKPaymentRequest *request = [Stripe
                             paymentRequestWithMerchantIdentifier:merchantId];

    // Configure your request here.
    NSString *label = [command.arguments objectAtIndex:1];
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[command.arguments objectAtIndex:0]];
    request.paymentSummaryItems = @[
        [PKPaymentSummaryItem summaryItemWithLabel:label
                                          amount:amount]
    ];

    NSString *cur = [command.arguments objectAtIndex:2];
    request.currencyCode = cur;

    callbackId = command.callbackId;


    if ([Stripe canSubmitPaymentRequest:request]) {
        PKPaymentAuthorizationViewController *paymentController;
        paymentController = [[PKPaymentAuthorizationViewController alloc]
                             initWithPaymentRequest:request];
        paymentController.delegate = self;
        [self.viewController presentViewController:paymentController animated:YES completion:nil];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"You dont have access to ApplePay"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {

    void(^tokenBlock)(STPToken *token, NSError *error) = ^void(STPToken *token, NSError *error) {
        if (error) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"couldn't get a stripe token from STPAPIClient"];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            return;
        }
        else {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: token.tokenId];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    };

    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                        completion:tokenBlock];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"user cancelled apple pay"];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
