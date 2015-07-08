angular.module('LocalHyper.common').factory('Push', [
  'App', '$cordovaPush', function(App, $cordovaPush) {
    var Push;
    Push = {};
    Push.register = function() {
      var androidConfig, config, iosConfig;
      androidConfig = {
        "senderID": "DUMMY_SENDER_ID"
      };
      iosConfig = {
        "badge": true,
        "sound": true,
        "alert": true
      };
      if (App.isWebView()) {
        config = App.isIOS() ? iosConfig : androidConfig;
        return $cordovaPush.register(config).then(function(success) {
          return console.log('Push Registration Success');
        }, function(error) {
          return console.log('Push Registration Error');
        });
      }
    };
    Push.getPayload = function(p) {
      var foreground, payload;
      payload = {};
      if (App.isAndroid()) {
        if (p.event === 'message') {
          payload = p.payload.data;
          payload.foreground = p.foreground;
          if (_.has(p, 'coldstart')) {
            payload.coldstart = p.coldstart;
          }
        }
      }
      if (App.isIOS()) {
        payload = p;
        foreground = p.foreground === "1" ? true : false;
        payload.foreground = foreground;
      }
      return payload;
    };
    Push.handlePayload = function(event, payload) {
      console.log('Notification received');
      return console.log(payload);
    };
    return Push;
  }
]);
