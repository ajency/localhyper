angular.module('LocalHyper.auth').controller('VerifyAutoCtrl', [
  '$scope', '$rootScope', 'App', 'SmsAPI', 'AuthAPI', function($scope, $rootScope, App, SmsAPI, AuthAPI) {
    var cordovaSmsPlugin, onSmsReceptionSuccess, register, requestSMSCode, sms, startSmsReception, stopSmsReception, verifySmsCode;
    $scope.view = {
      display: 'noError'
    };
    sms = {
      code: '',
      errorAt: ''
    };
    cordovaSmsPlugin = {
      enabled: App.isWebView() && App.isAndroid(),
      src: "info.asankan.phonegap.smsplugin.smsplugin"
    };
    register = function() {
      return AuthAPI.register($rootScope.user).then(function(success) {
        return App.navigate('categories', {}, {
          animate: false,
          back: false
        });
      }, function(error) {
        sms.errorAt = 'register';
        return $scope.view.display = 'error';
      });
    };
    verifySmsCode = function(code) {
      return SmsAPI.verifySMSCode($rootScope.user.phone, code).then(function(data) {
        if (data.verified) {
          return register();
        }
      }, function(error) {
        sms.errorAt = 'verifySmsCode';
        return $scope.view.display = 'error';
      });
    };
    onSmsReceptionSuccess = function(smsContent) {
      var code, content;
      content = smsContent.split('>');
      content = content[1];
      if (s.contains(content, 'Welcome to ShopOye')) {
        content = content.replace('[Nexmo DEMO]', '');
        code = s.words(content, 'code is');
        code = s.trim(code[1]);
        sms.code = code;
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
    requestSMSCode = function() {
      return SmsAPI.requestSMSCode($rootScope.user.phone).then(function(data) {
        console.log(data);
        if (data.attemptsExceeded) {
          return $scope.view.display = 'maxAttempts';
        }
      }, function(error) {
        sms.errorAt = 'requestSMSCode';
        return $scope.view.display = 'error';
      });
    };
    $scope.onTryAgain = function() {
      $scope.view.display = 'noError';
      switch (sms.errorAt) {
        case 'requestSMSCode':
          return requestSMSCode();
        case 'verifySmsCode':
          return verifySmsCode(sms.code);
        case 'register':
          return register();
      }
    };
    $scope.$on('$ionicView.loaded', function() {
      return requestSMSCode();
    });
    $scope.$on('$ionicView.enter', function() {
      return startSmsReception();
    });
    return $scope.$on('$ionicView.leave', function() {
      return stopSmsReception();
    });
  }
]);
