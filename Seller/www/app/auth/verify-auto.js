angular.module('LocalHyper.auth').controller('VerifyAutoCtrl', [
  '$scope', 'App', 'SmsAPI', 'AuthAPI', 'User', '$timeout', 'CToast', function($scope, App, SmsAPI, AuthAPI, User, $timeout, CToast) {
    $scope.view = {
      display: 'noError',
      smsCode: '',
      errorAt: '',
      errorType: '',
      timeout: null,
      smsPluginSrc: "info.asankan.phonegap.smsplugin.smsplugin",
      onError: function(type, at) {
        this.display = 'error';
        this.errorType = type;
        return this.errorAt = at;
      },
      startTimeout: function() {
        return this.timeout = $timeout(function() {
          return App.navigate('verify-manual');
        }, 40000);
      },
      cancelTimeout: function() {
        return $timeout.cancel(this.timeout);
      },
      isExistingUser: function() {
        return AuthAPI.isExistingUser(this.user).then((function(_this) {
          return function(data) {
            if (data.existing) {
              if (data.userObj[0].get('userType') === 'customer') {
                App.goBack(-1);
                return CToast.show('Sorry, you are already a registered customer');
              } else {
                return _this.requestSMSCode();
              }
            } else {
              return _this.requestSMSCode();
            }
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error, 'isExistingUser');
          };
        })(this));
      },
      requestSMSCode: function() {
        this.startTimeout();
        return SmsAPI.requestSMSCode(this.user.phone).then((function(_this) {
          return function(data) {
            console.log(data);
            if (data.attemptsExceeded) {
              _this.display = 'maxAttempts';
              return _this.cancelTimeout();
            }
          };
        })(this), (function(_this) {
          return function(error) {
            _this.onError(error, 'requestSMSCode');
            return _this.cancelTimeout();
          };
        })(this));
      },
      startSmsReception: function() {
        var onSuccess, smsplugin;
        onSuccess = (function(_this) {
          return function(smsContent) {
            var code, content;
            content = smsContent.split('>');
            content = content[1];
            if (s.contains(content, 'Welcome to ShopOye')) {
              _this.cancelTimeout();
              content = content.replace('[Nexmo DEMO]', '');
              code = s.words(content, 'code is');
              code = s.trim(code[1]);
              _this.smsCode = code;
              return _this.verifySmsCode();
            }
          };
        })(this);
        if (App.isWebView()) {
          smsplugin = cordova.require(this.smsPluginSrc);
          return smsplugin.startReception(onSuccess);
        }
      },
      stopSmsReception: function() {
        var smsplugin;
        if (App.isWebView()) {
          smsplugin = cordova.require(this.smsPluginSrc);
          return smsplugin.stopReception();
        }
      },
      verifySmsCode: function() {
        return SmsAPI.verifySMSCode(this.user.phone, this.smsCode).then((function(_this) {
          return function(data) {
            if (data.verified) {
              return _this.register();
            }
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error, 'verifySmsCode');
          };
        })(this));
      },
      register: function() {
        return AuthAPI.register(this.user).then(function(success) {
          Storage.bussinessDetails('remove');
          Storage.categoryChains('remove');
          return App.navigate('new-requests', {}, {
            animate: true,
            back: false
          });
        }, (function(_this) {
          return function(error) {
            return _this.onError(error, 'register');
          };
        })(this));
      },
      onTapToRetry: function() {
        this.display = 'noError';
        switch (this.errorAt) {
          case 'isExistingUser':
            return this.isExistingUser();
          case 'requestSMSCode':
            return this.requestSMSCode();
          case 'verifySmsCode':
            return this.verifySmsCode();
          case 'register':
            return this.register();
        }
      }
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      return $scope.view.user = User.info('get');
    });
    $scope.$on('$ionicView.enter', function() {
      $scope.view.startSmsReception();
      return $scope.view.isExistingUser();
    });
    return $scope.$on('$ionicView.leave', function() {
      $scope.view.stopSmsReception();
      return $scope.view.cancelTimeout();
    });
  }
]);
