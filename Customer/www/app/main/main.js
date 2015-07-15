angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', '$cordovaSocialSharing', '$cordovaAppRate', function($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, $cordovaSocialSharing, $cordovaAppRate) {
    $scope.view = {
      userPopover: null,
      init: function() {
        return this.loadPopOver();
      },
      loadPopOver: function() {
        return $ionicPopover.fromTemplateUrl('views/right-popover.html', {
          scope: $scope
        }).then((function(_this) {
          return function(popover) {
            return _this.userPopover = popover;
          };
        })(this));
      },
      onBackClick: function() {
        var count;
        if (App.currentState === 'verify-manual') {
          count = App.isAndroid() ? -2 : -1;
        } else {
          count = -1;
        }
        return App.goBack(count);
      },
      menuClose: function() {
        return $ionicSideMenuDelegate.toggleLeft();
      },
      onCallUs: function() {
        var telURI;
        this.menuClose();
        telURI = "tel:" + SUPPORT_NUMBER;
        return document.location.href = telURI;
      },
      onShare: function() {
        var link, msg, subject;
        subject = "Hey, have you tried " + APP_NAME;
        msg = "Now get the best offers from your local sellers. Visit";
        link = "https://play.google.com/store/apps/details?id=" + PACKAGE_NAME;
        if (App.isWebView()) {
          return $cordovaSocialSharing.share(msg, subject, "", link);
        }
      },
      onRateUs: function() {
        this.menuClose();
        if (App.isWebView()) {
          return $cordovaAppRate.promptForRating(true);
        }
      }
    };
    return $rootScope.$on('on:session:expiry', function() {
      console.log('on:session:expiry');
      return Parse.User.logOut();
    });
  }
]).config([
  '$stateProvider', '$cordovaAppRateProvider', function($stateProvider, $cordovaAppRateProvider) {
    if (ionic.Platform.isWebView()) {
      document.addEventListener("deviceready", function() {
        var customLocale, preferences;
        customLocale = {
          title: "Rate Us",
          message: ("If you enjoy using " + APP_NAME + ",") + " please take a moment to rate us." + " It won’t take more than a minute. Thanks for your support!",
          cancelButtonLabel: "No, Thanks",
          laterButtonLabel: "Remind Me Later",
          rateButtonLabel: "Rate Now"
        };
        preferences = {
          language: 'en',
          appName: APP_NAME,
          iosURL: PACKAGE_NAME,
          androidURL: "market://details?id=" + PACKAGE_NAME
        };
        $cordovaAppRateProvider.setCustomLocale(customLocale);
        return $cordovaAppRateProvider.setPreferences(preferences);
      });
    }
    return $stateProvider.state('main', {
      url: '/main',
      abstract: true,
      templateUrl: 'views/main.html'
    });
  }
]);
