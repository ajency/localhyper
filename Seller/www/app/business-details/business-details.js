angular.module('LocalHyper.businessDetails', ['ngAutocomplete']).controller('BusinessDetailsCtrl', [
  '$scope', function($scope) {
    return $scope.view = {
      businessName: '',
      fullName: '',
      businessPhoneNumber: ''
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('business-details', {
      url: '/business-details',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'BusinessDetailsCtrl',
          templateUrl: 'views/business-details/business-details.html',
          resolve: {
            GoogleMaps: function($q) {
              var defer, script;
              defer = $q.defer();
              script = document.createElement('script');
              script.type = 'text/javascript';
              script.src = "https://maps.googleapis.com/maps/api/js?libraries=places" + ("&key=" + GOOGLE_MAPS_API_KEY + "&callback=initialize");
              document.body.appendChild(script);
              window.initialize = function() {
                return defer.resolve();
              };
              return defer.promise;
            }
          }
        }
      }
    });
  }
]);
