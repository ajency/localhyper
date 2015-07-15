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
      call: function() {
        var call;
        call = "tel:9049678054";
        return document.location.href = call;
      },
      shareAnywhere: function() {
        var image, link, msg, sub;
        sub = "Hey, have you tried Shopoye.";
        msg = " You can get the best offers from your local sellers just on one click. I am sure you will like it.";
        link = "https://play.google.com/store/apps/details?id=com.facebook.katana&hl=en";
        image = "";
        return $cordovaSocialSharing.share(msg, sub, "", link);
      },
      rateUs: function() {
        return document.addEventListener("deviceready", function() {
          return $cordovaAppRate.promptForRating(true).then(function(result) {});
        });
      }
    };
    return $rootScope.$on('on:session:expiry', function() {
      console.log('on:session:expiry');
      return Parse.User.logOut();
    });
  }
]).config([
  '$stateProvider', '$cordovaAppRateProvider', function($stateProvider, $cordovaAppRateProvider) {
    document.addEventListener("deviceready", function() {
      var popupInfo;
      AppRate.preferences.useLanguage = 'en';
      popupInfo = {};
      popupInfo.title = "Rate Us";
      popupInfo.message = "In Love with the app ? Give us five star!";
      popupInfo.cancelButtonLabel = "No, thanks";
      popupInfo.laterButtonLabel = "Remind Me Later";
      popupInfo.rateButtonLabel = "Rate Now";
      AppRate.preferences.customLocale = popupInfo;
      AppRate.preferences.usesUntilPrompt = 1;
      AppRate.preferences.openStoreInApp = false;
      AppRate.preferences.storeAppURL.ios = '849930087';
      return AppRate.preferences.storeAppURL.android = 'market://details?id=com.jabong.android';
    });
    return $stateProvider.state('main', {
      url: '/main',
      abstract: true,
      templateUrl: 'views/main.html'
    });
  }
]);
