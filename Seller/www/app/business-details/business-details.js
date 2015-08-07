angular.module('LocalHyper.businessDetails', []).controller('BusinessDetailsCtrl', [
  '$scope', 'CToast', 'App', 'GPS', 'GoogleMaps', 'CDialog', 'User', '$ionicModal', '$timeout', 'Storage', 'BusinessDetails', 'AuthAPI', 'CSpinner', '$cordovaDatePicker', function($scope, CToast, App, GPS, GoogleMaps, CDialog, User, $ionicModal, $timeout, Storage, BusinessDetails, AuthAPI, CSpinner, $cordovaDatePicker) {
    $scope.view = {
      name: '',
      phone: '',
      businessName: '',
      confirmedAddress: '',
      terms: false,
      myProfileState: false,
      delivery: {
        radius: 10,
        plus: function() {
          if (this.radius < 100) {
            return this.radius++;
          }
        },
        minus: function() {
          if (this.radius > 1) {
            return this.radius--;
          }
        }
      },
      workingDays: [
        {
          name: 'Mon',
          value: 'Monday',
          selected: false
        }, {
          name: 'Tue',
          value: 'Tuesday',
          selected: false
        }, {
          name: 'Wed',
          value: 'Wednesday',
          selected: false
        }, {
          name: 'Thur',
          value: 'Thursday',
          selected: false
        }, {
          name: 'Fri',
          value: 'Friday',
          selected: false
        }, {
          name: 'Sat',
          value: 'Saturday',
          selected: false
        }, {
          name: 'Sun',
          value: 'Sunday',
          selected: false
        }
      ],
      workTimings: {
        start: '',
        end: ''
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
        return this.getStoredBusinessDetails();
      },
      getStoredBusinessDetails: function() {
        var details;
        details = BusinessDetails;
        if (!_.isNull(details)) {
          this.name = details.name;
          this.phone = details.phone;
          this.businessName = details.businessName;
          this.confirmedAddress = details.confirmedAddress;
          this.delivery.radius = details.deliveryRadius;
          this.latitude = details.latitude;
          this.longitude = details.longitude;
          this.location.latLng = new google.maps.LatLng(details.latitude, details.longitude);
          this.location.address = details.address;
          this.workTimings = details.workTimings;
          return this.workingDays = details.workingDays;
        }
      },
      loadLocationModal: function() {
        return $ionicModal.fromTemplateUrl('views/business-details/location.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.location.modal = modal;
          };
        })(this));
      },
      areWorkingDaysSelected: function() {
        var selected;
        selected = _.pluck(this.workingDays, 'selected');
        return _.contains(selected, true);
      },
      getNonWorkingDays: function() {
        var offDays;
        offDays = [];
        _.each(this.workingDays, (function(_this) {
          return function(days) {
            if (!days.selected) {
              return offDays.push(days.value);
            }
          };
        })(this));
        return offDays;
      },
      addWorkTimings: function(type) {
        var options;
        if (App.isWebView()) {
          options = {
            date: new Date(),
            mode: 'time',
            is24Hour: true,
            okText: 'Set',
            androidTheme: 5
          };
          return $cordovaDatePicker.show(options).then((function(_this) {
            return function(date) {
              return _this.workTimings[type] = moment(date).format('HH:mm:ss');
            };
          })(this));
        } else {
          this.workTimings.start = '9:00:00';
          return this.workTimings.end = '18:00:00';
        }
      },
      onChangeLocation: function() {
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
        } else if (!_.isUndefined(this.latitude)) {
          return $timeout((function(_this) {
            return function() {
              var latLng, loc;
              loc = {
                lat: _this.latitude,
                long: _this.longitude
              };
              latLng = _this.location.setMapCenter(loc);
              _this.location.map.setZoom(15);
              return _this.location.addMarker(latLng);
            };
          })(this), 200);
        }
      },
      onConfirmLocation: function() {
        if (!_.isNull(this.location.latLng) && this.location.addressFetch) {
          this.location.address.full = GoogleMaps.fullAddress(this.location.address);
          this.confirmedAddress = this.location.address.full;
          return this.location.modal.hide();
        } else {
          return CToast.show('Please wait, getting location details...');
        }
      },
      saveBussinessDetails: function() {
        return Storage.bussinessDetails('set', {
          name: this.name,
          phone: this.phone,
          businessName: this.businessName,
          address: this.location.address,
          confirmedAddress: this.confirmedAddress,
          latitude: this.latitude,
          longitude: this.longitude,
          deliveryRadius: this.delivery.radius,
          location: {
            address: this.location.address
          },
          delivery: {
            radius: this.delivery.radius
          },
          workTimings: this.workTimings,
          workingDays: this.workingDays,
          offDays: this.getNonWorkingDays()
        });
      },
      onNext: function() {
        var user;
        if (_.contains([this.businessName, this.name, this.phone], '')) {
          return CToast.show('Fill up all fields');
        } else if (_.isUndefined(this.phone)) {
          return CToast.show('Please enter valid phone number');
        } else if (this.confirmedAddress === '') {
          return CToast.show('Please select your location');
        } else if (!this.areWorkingDaysSelected()) {
          return CToast.show('Please select your working days');
        } else if (_.contains([this.workTimings.start, this.workTimings.end], '')) {
          return CToast.show('Please select your work timings');
        } else {
          this.latitude = this.location.latLng.lat();
          this.longitude = this.location.latLng.lng();
          this.offDays = this.getNonWorkingDays();
          if (App.previousState === 'my-profile' || (App.previousState === '' && User.getCurrent() !== null)) {
            User.info('set', $scope.view);
            CSpinner.show('', 'Please wait...');
            user = User.info('get');
            return AuthAPI.isExistingUser(user).then((function(_this) {
              return function(data) {
                return AuthAPI.loginExistingUser(data.userObj);
              };
            })(this)).then((function(_this) {
              return function(success) {
                _this.saveBussinessDetails();
                return App.navigate('my-profile');
              };
            })(this), (function(_this) {
              return function(error) {
                return CToast.show('Please try again data not saved');
              };
            })(this))["finally"](function() {
              return CSpinner.hide();
            });
          } else {
            User.info('set', $scope.view);
            this.saveBussinessDetails();
            return App.navigate('category-chains');
          }
        }
      }
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      if (App.previousState === 'my-profile' || (App.previousState === '' && User.getCurrent() !== null)) {
        return $scope.view.myProfileState = true;
      }
    });
    return $scope.$on('$ionicView.enter', function() {
      return App.hideSplashScreen();
    });
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
            BusinessDetails: function($q, CSpinner, GoogleMaps, Storage) {
              var defer;
              defer = $q.defer();
              CSpinner.show('', 'Please wait...');
              GoogleMaps.loadScript().then(function() {
                return Storage.bussinessDetails('get');
              }).then(function(details) {
                return defer.resolve(details);
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
