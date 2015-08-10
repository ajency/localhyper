angular.module('LocalHyper.common', []).factory('App', [
  '$cordovaSplashscreen', '$state', '$ionicHistory', '$ionicSideMenuDelegate', '$window', '$cordovaStatusbar', '$cordovaKeyboard', '$cordovaNetwork', '$timeout', '$q', '$ionicScrollDelegate', '$cordovaInAppBrowser', function($cordovaSplashscreen, $state, $ionicHistory, $ionicSideMenuDelegate, $window, $cordovaStatusbar, $cordovaKeyboard, $cordovaNetwork, $timeout, $q, $ionicScrollDelegate, $cordovaInAppBrowser) {
    var App;
    return App = {
      start: true,
      validateEmail: /^[a-z]+[a-z0-9._]+@[a-z]+\.[a-z.]{2,5}$/,
      onlyNumbers: /^\d+$/,
      menuEnabled: {
        left: false,
        right: false
      },
      previousState: '',
      currentState: '',
      isAndroid: function() {
        return ionic.Platform.isAndroid();
      },
      isIOS: function() {
        return ionic.Platform.isIOS();
      },
      isWebView: function() {
        return ionic.Platform.isWebView();
      },
      isOnline: function() {
        if (this.isWebView()) {
          return $cordovaNetwork.isOnline();
        } else {
          return navigator.onLine;
        }
      },
      deviceUUID: function() {
        if (this.isWebView()) {
          return device.uuid;
        } else {
          return 'DUMMYUUID';
        }
      },
      hideSplashScreen: function() {
        if (this.isWebView()) {
          return $timeout(function() {
            return $cordovaSplashscreen.hide();
          }, 500);
        }
      },
      hideKeyboardAccessoryBar: function() {
        if ($window.cordova && $window.cordova.plugins.Keyboard) {
          return $cordovaKeyboard.hideAccessoryBar(true);
        }
      },
      setStatusBarStyle: function() {
        if ($window.StatusBar) {
          return $cordovaStatusbar.style(0);
        }
      },
      closeKeyboard: function() {
        if (this.isWebView()) {
          return $cordovaKeyboard.close();
        }
      },
      noTapScroll: function() {
        return !this.isIOS();
      },
      navigate: function(state, params, opts) {
        var animate, back;
        if (params == null) {
          params = {};
        }
        if (opts == null) {
          opts = {};
        }
        if (!_.isEmpty(opts)) {
          animate = _.has(opts, 'animate') ? opts.animate : false;
          back = _.has(opts, 'back') ? opts.back : false;
          $ionicHistory.nextViewOptions({
            disableAnimate: !animate,
            disableBack: !back
          });
        }
        return $state.go(state, params);
      },
      goBack: function(count) {
        return $ionicHistory.goBack(count);
      },
      dragContent: function(bool) {
        return $ionicSideMenuDelegate.canDragContent(bool);
      },
      resize: function() {
        return $ionicScrollDelegate.resize();
      },
      scrollTop: function() {
        return $ionicScrollDelegate.scrollTop(true);
      },
      scrollBottom: function() {
        return $ionicScrollDelegate.scrollBottom(true);
      },
      toINR: function(number) {
        if (!_.isUndefined(number)) {
          number = number.toString();
          return number.replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
        } else {
          return '';
        }
      },
      humanize: function(str) {
        return s.humanize(str);
      },
      openLink: function(url) {
        var options;
        options = {
          location: 'yes'
        };
        return $cordovaInAppBrowser.open(url, '_system', options);
      },
      getInstallationId: function() {
        var defer;
        defer = $q.defer();
        if (this.isWebView()) {
          parsePlugin.getInstallationId(function(installationId) {
            return defer.resolve(installationId);
          }, function(error) {
            return defer.reject(error);
          });
        } else {
          defer.resolve('DUMMY_INSTALLATION_ID');
        }
        return defer.promise;
      }
    };
  }
]);
