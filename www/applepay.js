var ApplePay = {

    getAllowsApplePay: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            'ApplePay',
            'getAllowsApplePay',
            []
        );
    },

    setupStripe: function(successCallback, errorCallback, merchantId, stripePublishableKey) {
        cordova.exec(
            successCallback,
            errorCallback,
            'ApplePay',
            'setupStripe',
            [merchantId, stripePublishableKey]
        );
    },

    getStripeToken: function(successCallback, errorCallback, amount, name, cur) {
        cordova.exec(
            successCallback,
            errorCallback,
            'ApplePay',
            'getStripeToken',
            [amount, name, cur]
        );
    }

};

module.exports = ApplePay;
