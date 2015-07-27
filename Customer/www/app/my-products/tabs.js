angular.module('LocalHyper.myProducts', []).directive('ajRemoveBoxShadow', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          return $('.bar-header').removeClass('bar-light');
        });
      }
    };
  }
]).directive('ajAddBoxShadow', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          return $('.bar-header').addClass('bar-light');
        });
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('tabs', {
      url: "/tab",
      abstract: true,
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/my-products/tabs.html'
        }
      }
    }).state('open-requests', {
      url: '/open-requests',
      parent: 'tabs',
      views: {
        "openRequestsTab": {
          controller: 'OpenRequestCtrl',
          templateUrl: 'views/my-products/open-requests.html'
        }
      }
    }).state('requests-history', {
      url: '/requests-history',
      parent: 'tabs',
      views: {
        "productHistoryTab": {
          controller: 'ProductHistoryCtrl',
          templateUrl: 'views/my-products/product-history.html'
        }
      }
    });
  }
]);
