angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', '$cordovaSocialSharing', '$cordovaAppRate', 'User', 'Push', 'RequestAPI', function($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, $cordovaSocialSharing, $cordovaAppRate, User, Push, RequestAPI) {
    $scope.view = {
      userPopover: null,
      init: function() {
        Push.register();
        this.loadPopOver();
        if (User.isLoggedIn()) {
          this.getNotifications();
        }
        return $ionicSideMenuDelegate.edgeDragThreshold(true);
      },
      getNotifications: function() {
        return RequestAPI.getNotifications().then((function(_this) {
          return function(offerIds) {
            var notifications;
            notifications = _.size(offerIds);
            if (notifications > 0) {
              App.notification.badge = true;
              return App.notification.count = notifications;
            }
          };
        })(this));
      },
      loadPopOver: function() {
        return $ionicPopover.fromTemplateUrl('views/user-popover.html', {
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
        this.menuClose();
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
    $rootScope.$on('$user:registration:success', function() {
      App.notification.icon = true;
      return $scope.view.getNotifications();
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        if (App.notification.count === 0) {
          return $scope.view.getNotifications();
        } else {
          return App.notification.increment();
        }
      }
    });
    $rootScope.$on('push:notification:click', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        RequestAPI.requestDetails('set', {
          pushOfferId: payload.id
        });
        return App.navigate('request-details');
      }
    });
    return $rootScope.$on('on:session:expiry', function() {
      Parse.User.logOut();
      App.notification.icon = false;
      return App.notification.badge = false;
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
