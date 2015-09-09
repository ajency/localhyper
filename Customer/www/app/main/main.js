angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', '$cordovaSocialSharing', '$cordovaAppRate', 'User', 'Push', 'RequestAPI', function($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, $cordovaSocialSharing, $cordovaAppRate, User, Push, RequestAPI) {
    $scope.view = {
      userPopover: null,
      userProfile: {
        display: false,
        name: '',
        phone: '',
        set: function() {
          var user;
          user = User.getCurrent();
          this.name = user.get('displayName');
          this.phone = user.get('username');
          return this.display = true;
        }
      },
      init: function() {
        Push.register();
        this.loadPopOver();
        if (User.isLoggedIn()) {
          this.userProfile.set();
          this.getOpenRequestCount();
          this.getNotifications();
        }
        return $ionicSideMenuDelegate.edgeDragThreshold(true);
      },
      getNotifications: function() {
        return RequestAPI.getNotifications().then((function(_this) {
          return function(offerIds) {
            var notifications;
            notifications = _.size(offerIds);
            App.notification.badge = notifications > 0;
            return App.notification.count = notifications;
          };
        })(this));
      },
      getOpenRequestCount: function() {
        return RequestAPI.getOpenRequestCount().then(function(data) {
          App.notification.openRequests = data.requestCount;
          return App.notification.offers = data.offerCount;
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
        var count, forAndroid, forIOS;
        switch (App.currentState) {
          case 'verify-manual':
            count = App.isAndroid() ? -2 : -1;
            break;
          case 'verify-success':
            forAndroid = App.previousState === 'verify-manual' ? -4 : -3;
            forIOS = -3;
            count = App.isAndroid() ? forAndroid : forIOS;
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
        this.menuClose();
        return App.callSupport();
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
      },
      onHelp: function() {
        this.menuClose();
        return App.openLink(HELP_URL);
      }
    };
    $rootScope.$on('$user:registration:success', function() {
      App.notification.icon = true;
      $scope.view.userProfile.set();
      $scope.view.getOpenRequestCount();
      $scope.view.getNotifications();
      return App.resize();
    });
    $rootScope.$on('get:open:request:count', function() {
      return $scope.view.getOpenRequestCount();
    });
    $rootScope.$on('make:request:success', function() {
      return $scope.view.getOpenRequestCount();
    });
    $rootScope.$on('update:notifications:and:open:requests', function() {
      $scope.view.getNotifications();
      return $scope.view.getOpenRequestCount();
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        if (App.notification.count === 0) {
          $scope.view.getNotifications();
        } else {
          App.notification.increment();
        }
        return $scope.view.getOpenRequestCount();
      }
    });
    $rootScope.$on('push:notification:click', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        RequestAPI.requestDetails('set', {
          pushOfferId: payload.id
        });
        App.navigate('request-details');
      }
      if (payload.type === 'request_delivery_changed') {
        RequestAPI.requestDetails('set', {
          pushRequestId: payload.id
        });
        return App.navigate('request-details');
      }
    });
    return $rootScope.$on('on:session:expiry', function() {
      Parse.User.logOut();
      $scope.view.userProfile.display = false;
      App.notification.icon = false;
      App.notification.badge = false;
      return App.resize();
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
