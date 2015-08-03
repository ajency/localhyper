angular.module('LocalHyper.profile', []).controller('ProfileCtrl', [
  '$scope', 'User', 'App', 'CDialog', 'GPS', 'CToast', 'GoogleMaps', '$ionicModal', function($scope, User, App, CDialog, GPS, CToast, GoogleMaps, $ionicModal) {
    var user;
    user = User.getCurrent();
    $scope.view = {
      name: user.get('displayName'),
      phone: "+91-" + (user.get('username')),
      profileAddress: '',
      permanentAddress: {
        obj: user.get('permanentAddress'),
        available: function() {
          return !_.isUndefined(this.obj);
        }
      },
      tempAddress: {
        obj: user.get('address'),
        available: function() {
          return !_.isUndefined(this.obj);
        }
      },
      location: {
        modal: null,
        map: null,
        marker: null,
        latLng: null,
        address: null,
        addressFetch: true,
        showAlert: function() {
          var positiveBtn;
          positiveBtn = App.isAndroid() ? 'Open Settings' : 'Ok';
          return CDialog.confirm('Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']).then(function(btnIndex) {
            if (btnIndex === 1) {
              return GPS.switchToLocationSettings();
            }
          });
        },
        onMapCreated: function(map) {
          this.map = map;
          return google.maps.event.addListener(this.map, 'click', (function(_this) {
            return function(event) {
              return _this.addMarker(event.latLng);
            };
          })(this));
        },
        setMapCenter: function(loc) {
          var latLng;
          latLng = new google.maps.LatLng(loc.lat, loc.long);
          this.map.setCenter(latLng);
          return latLng;
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
                  latLng = _this.setMapCenter(loc);
                  _this.map.setZoom(15);
                  return _this.addMarker(latLng);
                }, function(error) {
                  return CToast.show('Error locating your position');
                });
              }
            };
          })(this));
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
          this.addressFetch = false;
          return GoogleMaps.getAddress(this.latLng).then((function(_this) {
            return function(address) {
              return _this.address = address;
            };
          })(this), function(error) {
            return console.log('Geocode error: ' + error);
          })["finally"]((function(_this) {
            return function() {
              return _this.addressFetch = true;
            };
          })(this));
        }
      },
      init: function() {
        this.loadLocationModal();
        return this.checkForAddress();
      },
      loadLocationModal: function() {
        return $ionicModal.fromTemplateUrl('views/location.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.location.modal = modal;
          };
        })(this));
      },
      checkForAddress: function() {
        if (this.permanentAddress.available()) {
          return this.profileAddress = this.permanentAddress.obj.full;
        } else if (this.tempAddress.available()) {
          return this.profileAddress = this.tempAddress.obj.full;
        }
      },
      onEditLocation: function() {
        var mapHeight;
        this.location.modal.show();
        mapHeight = $('.map-content').height() - $('.address-inputs').height() - 10;
        $('.aj-big-map').css({
          'height': mapHeight
        });
        if (_.isNull(this.location.latLng)) {
          return $timeout((function(_this) {
            return function() {
              var loc;
              loc = {
                lat: GEO_DEFAULT.lat,
                long: GEO_DEFAULT.lng
              };
              _this.location.setMapCenter(loc);
              return _this.location.getCurrent();
            };
          })(this), 200);
        }
      },
      onConfirmLocation: function() {
        if (!_.isNull(this.location.latLng) && this.location.addressFetch) {
          return CDialog.confirm('Confirm Location', 'Do you want to confirm this location?', ['Confirm', 'Cancel']).then((function(_this) {
            return function(btnIndex) {
              if (btnIndex === 1) {
                _this.location.address.full = GoogleMaps.fullAddress(_this.location.address);
                _this.confirmedAddress = _this.location.address.full;
                return _this.location.modal.hide();
              }
            };
          })(this));
        } else {
          return CToast.show('Please wait, getting location details...');
        }
      }
    };
    $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
    return $scope.$on('$destroy', function() {
      return $scope.view.location.modal.remove();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('profile', {
      url: '/Seller-profile',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'ProfileCtrl',
          templateUrl: 'views/profile/profile.html',
          resolve: {
            Maps: function($q, CSpinner, GoogleMaps) {
              var defer;
              defer = $q.defer();
              CSpinner.show('', 'Please wait...');
              GoogleMaps.loadScript().then(function() {
                return defer.resolve();
              })["finally"](function() {
                return CSpinner.hide();
              });
              return defer.promise;
            }
          }
        }
      }
    });
  }
]);
