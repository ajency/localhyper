angular.module('LocalHyper.businessDetails', ['ngAutocomplete']).controller('BusinessDetailsCtrl', [
  '$scope', 'CToast', 'App', 'GPS', 'GoogleMaps', 'CDialog', 'User', function($scope, CToast, App, GPS, GoogleMaps, CDialog, User) {
    $scope.view = {
      businessName: 'Ajency',
      name: 'Deepak',
      phone: '9765436351',
      map: null,
      marker: null,
      latLng: null,
      geoCode: null,
      address: null,
      fullAddress: '',
      addrReqComplete: true,
      deliveryRadius: 2,
      terms: false,
      addressConfirmed: false,
      init: function() {
        return this.getCurrentLocation();
      },
      onMapCreated: function(map) {
        this.map = map;
        return google.maps.event.addListener(this.map, 'click', (function(_this) {
          return function(event) {
            return _this.addMarker(event.latLng);
          };
        })(this));
      },
      getCurrentLocation: function() {
        CToast.show('Getting current location');
        return GPS.getCurrentLocation().then((function(_this) {
          return function(loc) {
            var latLng;
            latLng = new google.maps.LatLng(loc.lat, loc.long);
            _this.map.setCenter(latLng);
            _this.map.setZoom(15);
            return _this.addMarker(latLng);
          };
        })(this), function(err) {
          return CToast.show('Error locating your position');
        });
      },
      addMarker: function(latLng) {
        this.latLng = latLng;
        this.setAddress();
        if (this.marker) {
          this.marker.setMap(null);
        }
        this.marker = new google.maps.Marker({
          position: latLng,
          map: this.map,
          draggable: true
        });
        this.marker.setMap(this.map);
        return google.maps.event.addListener(this.marker, 'dragend', (function(_this) {
          return function(event) {
            _this.latLng = event.latLng;
            return _this.setAddress();
          };
        })(this));
      },
      setAddress: function() {
        this.addrReqComplete = false;
        return GoogleMaps.getAddress(this.latLng).then((function(_this) {
          return function(address) {
            _this.address = address;
            return _this.fullAddress = address.full;
          };
        })(this), function(error) {
          return console.log('Geocode error: ' + error);
        })["finally"]((function(_this) {
          return function() {
            return _this.addrReqComplete = true;
          };
        })(this));
      },
      onConfirmLocation: function() {
        if (!_.isNull(this.latLng) && this.addrReqComplete) {
          return CDialog.confirm('Confirm Location', 'Do you want to confirm this location?', ['Confirm', 'Cancel']).then((function(_this) {
            return function(btnIndex) {
              if (btnIndex === 1) {
                return _this.addressConfirmed = true;
              }
            };
          })(this));
        } else {
          return CToast.show('Please wait...');
        }
      },
      onNext: function() {
        if (_.contains([this.businessName, this.name, this.phone], '')) {
          return CToast.show('Fill up all fields');
        } else if (_.isUndefined(this.phone)) {
          return CToast.show('Please enter valid phone number');
        } else if (!this.addressConfirmed) {
          return CToast.show('Please confirm your location');
        } else {
          this.geoCode = {
            latitude: this.latLng.lat(),
            longitude: this.latLng.lng()
          };
          User.info('set', $scope.view);
          return App.navigate('categories');
        }
      }
    };
    return $scope.$on('$ionicView.enter', function() {
      return App.hideSplashScreen();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('business-details', {
      url: '/business-details',
      parent: 'main',
      views: {
        "appContent": {
          controller: 'BusinessDetailsCtrl',
          templateUrl: 'views/business-details/business-details.html',
          resolve: {
            Maps: function(GoogleMaps) {
              if (typeof google === "undefined") {
                return GoogleMaps.loadScript();
              }
            }
          }
        }
      }
    });
  }
]);
