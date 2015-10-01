angular.module('LocalHyper.businessDetails', []).controller('BusinessDetailsCtrl', [
  '$scope', 'CToast', 'App', 'GPS', 'GoogleMaps', 'CDialog', 'User', '$timeout', 'Storage', 'BusinessDetails', 'AuthAPI', 'CSpinner', '$q', '$rootScope', '$ionicPlatform', function($scope, CToast, App, GPS, GoogleMaps, CDialog, User, $timeout, Storage, BusinessDetails, AuthAPI, CSpinner, $q, $rootScope, $ionicPlatform) {
    var onDeviceBack;
    $scope.view = {
      name: '',
      phone: '',
      businessName: '',
      confirmedAddress: '',
      terms: false,
      myProfileState: User.isLoggedIn() ? true : false,
      delivery: {
        radius: 10,
        plus: function() {
          if (this.radius < 25) {
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
      location: {
        modal: null,
        map: null,
        marker: null,
        latLng: null,
        address: null,
        addressFetch: true
      },
      init: function() {
        return this.getStoredBusinessDetails();
      },
      getStoredBusinessDetails: function() {
        var cordinates, details, userInfo, value;
        details = BusinessDetails;
        if (!_.isNull(details)) {
          this.name = details.name;
          this.phone = details.phone;
          this.businessName = details.businessName;
          this.confirmedAddress = details.confirmedAddress;
          this.delivery.radius = details.deliveryRadius;
          this.latitude = details.latitude;
          this.longitude = details.longitude;
          this.location.address = details.address;
          this.workingDays = details.workingDays;
          if (App.previousState === 'choose-location') {
            cordinates = GoogleMaps.setCordinates('get');
            if (!_.isEmpty(cordinates)) {
              this.latitude = cordinates.latitude;
              this.longitude = cordinates.longitude;
              if (!_.isUndefined(cordinates.addressObj)) {
                this.confirmedAddress = cordinates.addressObj.full;
              }
              return this.location.address = cordinates.addressObj;
            }
          } else {
            value = {
              latitude: this.latitude,
              longitude: this.longitude
            };
            return GoogleMaps.setCordinates('set', value);
          }
        } else {
          userInfo = User.info('get');
          if (!_.isUndefined(userInfo.name)) {
            this.name = userInfo.name;
          }
          if (!_.isUndefined(userInfo.phone)) {
            this.phone = userInfo.phone;
          }
          if (!_.isUndefined(userInfo.businessName)) {
            this.businessName = userInfo.businessName;
          }
          cordinates = GoogleMaps.setCordinates('get');
          if (!_.isEmpty(cordinates)) {
            this.latitude = cordinates.latitude;
            this.longitude = cordinates.longitude;
            this.confirmedAddress = cordinates.addressObj.full;
            return this.location.address = cordinates.addressObj;
          }
        }
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
      onChangeLocation: function() {
        User.info('set', $scope.view);
        CSpinner.show('', 'Please wait, loading resources');
        return GoogleMaps.loadScript().then((function(_this) {
          return function() {
            return App.navigate('choose-location');
          };
        })(this), function(error) {
          return CToast.show('Error loading content, please check your network settings');
        })["finally"](function() {
          return CSpinner.hide();
        });
      },
      onNext: function() {
        if (_.contains([this.businessName, this.name, this.phone], '')) {
          return CToast.show('Please fill up all fields');
        } else if (_.isUndefined(this.phone)) {
          return CToast.show('Please enter valid phone number');
        } else if (this.confirmedAddress === '') {
          return CToast.show('Please select your location');
        } else if (!this.areWorkingDaysSelected()) {
          return CToast.show('Please select your working days');
        } else {
          this.offDays = this.getNonWorkingDays();
          if (this.myProfileState) {
            CSpinner.show('', 'Please wait...');
            User.info('set', $scope.view);
            return AuthAPI.isExistingUser($scope.view).then(function(data) {
              return AuthAPI.loginExistingUser(data.userObj);
            }).then((function(_this) {
              return function(success) {
                CToast.show('Saved business details');
                $rootScope.$broadcast('category:chain:updated');
                return _this.saveBussinessDetails().then(function() {
                  return App.navigate('my-profile');
                });
              };
            })(this), function(error) {
              return CToast.show('Could not connect to server, please try again.');
            })["finally"](function() {
              return CSpinner.hide();
            });
          } else {
            User.info('set', $scope.view);
            return this.saveBussinessDetails().then(function() {
              return App.navigate('category-chains');
            });
          }
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
          workingDays: this.workingDays,
          offDays: this.getNonWorkingDays()
        });
      }
    };
    onDeviceBack = function() {
      return App.goBack(-1);
    };
    $scope.$on('$destroy', function() {
      return $ionicPlatform.offHardwareBackButton(onDeviceBack);
    });
    return $scope.$on('$ionicView.enter', function() {
      $ionicPlatform.onHardwareBackButton(onDeviceBack);
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
            BusinessDetails: function($q, Storage) {
              var defer;
              defer = $q.defer();
              Storage.bussinessDetails('get').then(function(details) {
                return defer.resolve(details);
              });
              return defer.promise;
            }
          }
        }
      }
    });
  }
]);
