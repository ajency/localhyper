angular.module('LocalHyper.auth').controller('RegisterCtrl', [
  '$scope', 'AuthAPI', 'App', 'CSpinner', 'SmsAPI', function($scope, AuthAPI, App, CSpinner, SmsAPI) {
    var cordovaSmsPlugin, onSmsReceptionSuccess, promptForSmsCode, register, startSmsReception, stopSmsReception, verifySmsCode;
    $scope.register = {
      name: 'Deepak',
      phone: 9765436351,
      maxAttempts: false
    };
    cordovaSmsPlugin = {
      enabled: App.isWebView() && App.isAndroid(),
      src: "info.asankan.phonegap.smsplugin.smsplugin"
    };
    register = function() {
      CSpinner.show('Authenticating...', 'Please wait...');
      return AuthAPI.register($scope.register).then(function(success) {
        console.log('Registration success');
        return console.log(success);
      }, function(error) {
        return console.log(error);
      })["finally"](function() {
        return CSpinner.hide();
      });
    };
    verifySmsCode = function(code) {
      CSpinner.show('Verifying...', 'Please wait...');
      return SmsAPI.verifySMSCode($scope.register.phone, code).then(function(data) {
        if (data.verified) {
          return register();
        } else {
          return console.log('Invalid verification code');
        }
      }, function(error) {
        return console.log('Error verifying sms code');
      })["finally"](function() {
        return CSpinner.hide();
      });
    };
    onSmsReceptionSuccess = function(smsContent) {
      var code, content;
      console.log(smsContent);
      content = smsContent.split('>');
      content = content[1];
      if (s.contains(content, 'code')) {
        CSpinner.hide();
        code = s.words(content, ':');
        code = s.trim(code[1]);
        return verifySmsCode(code);
      }
    };
    startSmsReception = function() {
      var smsplugin;
      if (cordovaSmsPlugin.enabled) {
        smsplugin = cordova.require(cordovaSmsPlugin.src);
        return smsplugin.startReception(onSmsReceptionSuccess);
      }
    };
    stopSmsReception = function() {
      var smsplugin;
      if (cordovaSmsPlugin.enabled) {
        smsplugin = cordova.require(cordovaSmsPlugin.src);
        return smsplugin.stopReception();
      }
    };
    promptForSmsCode = function() {
      if (App.isIOS()) {
        return CSpinner.hide();
      }
    };
    $scope.requestSMSCode = function() {
      if (App.isOnline()) {
        if (App.isAndroid()) {
          CSpinner.show('Waiting for verification code', 'Please do not close the app...');
        } else if (App.isIOS()) {
          CSpinner.show('Sending verification code', 'Please wait...');
        }
        return SmsAPI.requestSMSCode($scope.register.phone).then(function(data) {
          if (data.attemptsExceeded) {
            CSpinner.hide();
            return $scope.register.maxAttempts = true;
          } else {
            return promptForSmsCode();
          }
        }, function(error) {
          return CSpinner.hide();
        });
      }
    };
    $scope.$on('$ionicView.enter', function() {
      return startSmsReception();
    });
    return $scope.$on('$ionicView.unloaded', function() {
      return stopSmsReception();
    });
  }
]);
