angular.module('LocalHyper.common', []).factory('App', [
  '$cordovaSplashscreen', '$state', '$ionicHistory', '$ionicSideMenuDelegate', '$window', '$cordovaStatusbar', '$cordovaKeyboard', function($cordovaSplashscreen, $state, $ionicHistory, $ionicSideMenuDelegate, $window, $cordovaStatusbar, $cordovaKeyboard) {
    var App;
    return App = {
      start: true,
      validateEmail: /^[a-z]+[a-z0-9._]+@[a-z]+\.[a-z.]{2,5}$/,
      menuEnabled: {
        left: false,
        right: false
      },
      isAndroid: function() {
        return ionic.Platform.isAndroid();
      },
      isIOS: function() {
        return ionic.Platform.isIOS();
      },
      isWebView: function() {
        return ionic.Platform.isWebView();
      },
      hideSplashScreen: function() {
        if (this.isWebView()) {
          return $cordovaSplashscreen.hide();
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
      noTapScroll: function() {
        return "" + (!this.isIOS());
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
      goBack: function() {
        return $ionicHistory.goBack();
      },
      dragContent: function(bool) {
        return $ionicSideMenuDelegate.canDragContent(bool);
      }
    };
  }
]);
