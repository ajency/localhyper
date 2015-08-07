angular.module('LocalHyper.profile', []).controller('ProfileCtrl', [
  '$q', '$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI', 'AuthAPI', 'CSpinner', 'CategoryChains', '$rootScope', 'BussinessDetails', function($q, $scope, User, App, CToast, Storage, CategoriesAPI, AuthAPI, CSpinner, CategoryChains, $rootScope, BussinessDetails) {
    $scope.view = {
      showDelete: false,
      businessName: '',
      phone: '',
      categoryChains: [],
      setCategoryChains: function() {
        this.categoryChains = CategoryChains;
        this.businessName = BussinessDetails.businessName;
        return this.phone = BussinessDetails.phone;
      },
      getBrands: function(brands) {
        var brandNames;
        brandNames = _.pluck(brands, 'name');
        return brandNames.join(', ');
      },
      onChainClick: function(chains) {
        CategoriesAPI.subCategories('set', chains.category.children);
        return App.navigate('brands', {
          categoryID: chains.subCategory.id
        });
      },
      removeItemFromChains: function(subCategoryId) {
        var spliceIndex;
        this.categoryChains = CategoriesAPI.categoryChains('get');
        spliceIndex = _.findIndex(this.categoryChains, function(chains) {
          return chains.subCategory.id === subCategoryId;
        });
        return this.categoryChains.splice(spliceIndex, 1);
      },
      saveDetails: function() {
        return Storage.bussinessDetails('get').then((function(_this) {
          return function(details) {
            var user;
            User.info('reset', details);
            user = User.info('get');
            CSpinner.show('', 'Please wait...');
            return AuthAPI.isExistingUser(user).then(function(data) {
              CSpinner.hide();
              return AuthAPI.loginExistingUser(data.userObj);
            }).then(function(success) {
              CategoriesAPI.categoryChains('set', _this.categoryChains);
              Storage.categoryChains('set', _this.categoryChains);
              $rootScope.$broadcast('category:chain:changed');
              return CToast.show('Details saved');
            }, function(error) {
              return CToast.show('Please try again data not saved');
            })["finally"](function() {
              return CSpinner.hide();
            });
          };
        })(this));
      }
    };
    $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
    $scope.$on('$ionicView.enter', function() {});
    return $scope.$on('$ionicView.leave', function() {
      var categoryChainSet;
      categoryChainSet = true;
      return Storage.categoryChains('get').then(function(chains) {
        if (App.currentState === 'categories' || App.currentState === 'sub-categories' || App.currentState === 'brands') {
          categoryChainSet = false;
        } else {
          categoryChainSet = true;
        }
        if (categoryChainSet === true) {
          return CategoriesAPI.categoryChains('set', chains);
        }
      });
    });
  }
]).config([
  '$stateProvider', function($stateProvider, Storage, CategoriesAPI) {
    return $stateProvider.state('my-profile', {
      url: '/seller-profile',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'ProfileCtrl',
          templateUrl: 'views/profile/profile.html',
          resolve: {
            CategoryChains: function($q, Storage, CategoriesAPI) {
              var chains, defer;
              chains = CategoriesAPI.categoryChains('get');
              defer = $q.defer();
              if (chains.length === 0) {
                defer = $q.defer();
                Storage.categoryChains('get').then(function(chains) {
                  CategoriesAPI.categoryChains('set', chains);
                  return defer.resolve(chains);
                });
              } else {
                defer.resolve(chains);
              }
              return defer.promise;
            },
            BussinessDetails: function($q, Storage) {
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
