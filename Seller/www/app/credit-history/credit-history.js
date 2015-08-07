angular.module('LocalHyper.creditHistory', []).controller('creditHistoryCtrl', ['$scope', 'App', 'CategoriesAPI', 'Storage', 'RequestsAPI', 'DeliveryTime', function($scope, App, CategoriesAPI, Storage, RequestsAPI, DeliveryTime) {}]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('credit-history', {
      url: '/credit-history',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/credit-history/credit-history.html',
          controller: 'creditHistoryCtrl'
        }
      }
    });
  }
]);
