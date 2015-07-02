angular.module('LocalHyper.init').controller('SlideTutorialCtrl', [
  '$scope', 'App', 'Storage', '$ionicSlideBoxDelegate', function($scope, App, Storage, $ionicSlideBoxDelegate) {
    $scope.slide = {
      active: 0
    };
    $scope.$on('$ionicView.afterEnter', function() {
      $ionicSlideBoxDelegate.enableSlide(false);
      return App.hideSplashScreen();
    });
    $scope.onSlideChange = function(index) {
      $scope.slide.active = index;
      if (index === 0 || index === 4) {
        return $ionicSlideBoxDelegate.enableSlide(false);
      }
    };
    $scope.onSlideRight = function() {
      var slide;
      slide = $scope.slide.active !== 0 ? true : false;
      return $ionicSlideBoxDelegate.enableSlide(slide);
    };
    $scope.onSlideLeft = function() {
      var slide;
      slide = $scope.slide.active !== 4 ? true : false;
      return $ionicSlideBoxDelegate.enableSlide(slide);
    };
    return $scope.onGetStarted = function() {
      return Storage.slideTutorial('set').then(function() {
        return App.navigate("departments", {}, {
          animate: false,
          back: false
        });
      });
    };
  }
]).directive('ajFitToScreen', [
  '$timeout', '$ionicSlideBoxDelegate', function($timeout, $ionicSlideBoxDelegate) {
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
      templateUrl: 'views/init/slide-tutorial.html',
      controller: 'SlideTutorialCtrl'
    });
  }
]);
