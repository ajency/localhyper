angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', 'CSpinner', '$timeout', 'Push', 'User', 'RequestsAPI', '$cordovaSocialSharing', '$cordovaAppRate', 'OffersAPI', function($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, CSpinner, $timeout, Push, User, RequestsAPI, $cordovaSocialSharing, $cordovaAppRate, OffersAPI) {
    $scope.view = {
      userPopover: null,
      init: function() {
        Push.register();
        this.loadPopOver();
        if (User.isLoggedIn()) {
          this.getNotifications();
          this.getCountOfAcceptedOffers();
        }
        return $ionicSideMenuDelegate.edgeDragThreshold(true);
      },
      getNotifications: function() {
        return RequestsAPI.getNotifications().then((function(_this) {
          return function(requestIds) {
            var notifications;
            notifications = _.size(requestIds);
            if (notifications > 0) {
              App.notification.badge = true;
              return App.notification.count = notifications;
            }
          };
        })(this));
      },
      getCountOfAcceptedOffers: function() {
        return OffersAPI.getAcceptedOfferCount().then(function(count) {
          return App.notification.accptedOffers = count;
        });
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
        switch (App.currentState) {
          case 'verify-manual':
            count = App.isAndroid() ? -2 : -1;
            break;
          default:
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
        msg = "Now sell products to your local crowd with just a click. Visit";
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
      },
      onHelp: function() {
        this.menuClose();
        return App.openLink(HELP_URL);
      }
    };
    $rootScope.$on('get:unseen:notifications', function(e, obj) {
      return $scope.view.getNotifications();
    });
    $rootScope.$on('get:accepted:offer:count', function(e, obj) {
      return $scope.view.getCountOfAcceptedOffers();
    });
    $rootScope.$on('$user:registration:success', function() {
      App.notification.icon = true;
      return $scope.view.getNotifications();
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_request') {
        if (App.notification.count === 0) {
          return $scope.view.getNotifications();
        } else {
          return App.notification.increment();
        }
      }
    });
    return $rootScope.$on('on:session:expiry', function() {
      CSpinner.show('', 'Your session has expired, please wait...');
      return $timeout(function() {
        Parse.User.logOut();
        App.notification.icon = false;
        App.notification.badge = false;
        App.navigate('business-details', {}, {
          animate: true,
          back: false
        });
        return CSpinner.hide();
      }, 2000);
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
