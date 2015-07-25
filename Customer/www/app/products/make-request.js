angular.module('LocalHyper.products').controller('MakeRequestCtrl', [
  '$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout', function($scope, App, GPS, CToast, CDialog, $timeout) {
    $scope.view = {
      latLng: null,
      addressFetch: true,
      toLatLng: function(loc) {
        var latLng;
        latLng = new google.maps.LatLng(loc.lat, loc.long);
        return latLng;
      },
      onMapCreated: function(map) {
        this.map = map;
        return google.maps.event.addListener(this.map, 'click', (function(_this) {
          return function(event) {
            return _this.addPlaceMarker(event.latLng);
          };
        })(this));
      },
      onPlacedChange: function(latLng) {
        this.latLng - latLng;
        this.map.setCenter(latLng);
        this.map.setZoom(15);
        return this.addPlaceMarker(latLng);
      },
      init: function() {
        if (_.isNull(this.latLng)) {
          return $timeout((function(_this) {
            return function() {
              var loc;
              loc = {
                lat: GEO_DEFAULT.lat,
                long: GEO_DEFAULT.lng
              };
              _this.map.setCenter(_this.toLatLng(loc));
              return _this.getCurrent();
            };
          })(this), 200);
        }
      },
      getCurrent: function() {
        return GPS.isLocationEnabled().then((function(_this) {
          return function(enabled) {
            if (!enabled) {
              return _this.showAlert();
            } else {
              CToast.show('Getting current location');
              return GPS.getCurrentLocation().then(function(loc) {
                var latLng;
                latLng = _this.toLatLng(loc);
                _this.map.setCenter(latLng);
                _this.map.setZoom(15);
                return _this.addUserLocationMarker(latLng);
              }, function(error) {
                return CToast.show('Error locating your position');
              });
            }
          };
        })(this));
      },
      addUserLocationMarker: function(latLng) {
        this.latLng = latLng;
        if (this.userMarker) {
          this.userMarker.setMap(null);
        }
        if (this.placeMarker) {
          this.placeMarker.setMap(null);
        }
        this.userMarker = new google.maps.Marker({
          position: latLng,
          map: this.map,
          icon: 'img/current-location.png'
        });
        return this.userMarker.setMap(this.map);
      },
      addPlaceMarker: function(latLng) {
        this.latLng = latLng;
        if (this.placeMarker) {
          this.placeMarker.setMap(null);
        }
        this.placeMarker = new google.maps.Marker({
          position: latLng,
          map: this.map,
          draggable: true
        });
        this.placeMarker.setMap(this.map);
        return google.maps.event.addListener(this.placeMarker, 'dragend', (function(_this) {
          return function(event) {
            return _this.latLng = event.latLng;
          };
        })(this));
      },
      showAlert: function() {
        var positiveBtn;
        positiveBtn = App.isAndroid() ? 'Open Settings' : 'Ok';
        return CDialog.confirm('Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']).then(function(btnIndex) {
          if (btnIndex === 1) {
            return GPS.switchToLocationSettings();
          }
        });
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function() {});
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('make-request', {
      url: '/make-request',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/make-request.html',
          controller: 'MakeRequestCtrl'
        }
      }
    });
  }
]);
