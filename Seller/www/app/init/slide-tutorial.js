angular.module('LocalHyper.init').controller('SlideTutorialCtrl', [
  '$scope', 'App', 'Storage', '$ionicSlideBoxDelegate', 'User', function($scope, App, Storage, $ionicSlideBoxDelegate, User) {
    $scope.view = {
      activeSlide: 0,
      slide: function(bool) {
        return $ionicSlideBoxDelegate.enableSlide(bool);
      },
      onGetStarted: function() {
        return Storage.slideTutorial('set').then(function() {
          var goto;
          goto = User.isLoggedIn() ? "categories" : 'business-details';
          return App.navigate(goto, {}, {
            animate: false,
            back: false
          });
        });
      },
      onSlideChange: function(index) {
        this.activeSlide = index;
        if (index === 0 || index === 4) {
          return this.slide(false);
        }
      },
      onSlideRight: function() {
        var bool;
        bool = this.activeSlide !== 0 ? true : false;
        return this.slide(bool);
      },
      onSlideLeft: function() {
        var bool;
        bool = this.activeSlide !== 4 ? true : false;
        return this.slide(bool);
      }
    };
    return $scope.$on('$ionicView.afterEnter', function() {
      $scope.view.slide(false);
      return App.hideSplashScreen();
    });
  }
]).directive('ajFitToScreen', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          return $('.aj-slide-img').css({
            width: $(window).width(),
            height: $(window).height()
          });
        });
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('tutorial', {
      url: '/tutorial',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/init/slide-tutorial.html',
          controller: 'SlideTutorialCtrl'
        }
      }
    });
  }
]);
