angular.module('LocalHyper.profile', []).controller('ProfileCtrl', [
  '$q', '$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI', 'AuthAPI', 'CSpinner', 'CategoryChains', '$rootScope', 'BussinessDetails', function($q, $scope, User, App, CToast, Storage, CategoriesAPI, AuthAPI, CSpinner, CategoryChains, $rootScope, BussinessDetails) {
    $scope.view = {
      showDelete: false,
      categoryChains: [],
      init: function() {
        this.showDelete = false;
        this.categoryChains = [];
        this.businessName = BussinessDetails.businessName;
        this.phone = BussinessDetails.phone;
        this.name = BussinessDetails.name;
        return this.setCategoryChains();
      },
      setCategoryChains: function() {
        this.categoryChains = CategoryChains;
        return CategoriesAPI.categoryChains('set', CategoryChains);
      },
      getBrands: function(brands) {
        var brandNames;
        brandNames = _.pluck(brands, 'name');
        return brandNames.join(', ');
      },
      removeItemFromChains: function(subCategoryId) {
        var spliceIndex;
        this.categoryChains = CategoriesAPI.categoryChains('get');
        spliceIndex = _.findIndex(this.categoryChains, function(chains) {
          return chains.subCategory.id === subCategoryId;
        });
        return this.categoryChains.splice(spliceIndex, 1);
      },
      onChainClick: function(chains) {
        CategoriesAPI.subCategories('set', chains.category.children);
        return App.navigate('brands', {
          categoryID: chains.subCategory.id
        });
      },
      saveDetails: function() {
        return Storage.bussinessDetails('get').then((function(_this) {
          return function(user) {
            CSpinner.show('', 'Please wait...');
            User.info('set', user);
            return AuthAPI.isExistingUser(user).then(function(data) {
              return AuthAPI.loginExistingUser(data.userObj);
            }).then(function(success) {
              return Storage.categoryChains('set', _this.categoryChains).then(function() {
                CategoriesAPI.categoryChains('set', _this.categoryChains);
                $rootScope.$broadcast('category:chain:updated');
                CSpinner.hide();
                return CToast.show('Saved profile details');
              });
            }, function(error) {
              CToast.show('Could not connect to server, please try again.');
              return CSpinner.hide();
            });
          };
        })(this));
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
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
            CategoryChains: function($q, Storage) {
              var defer;
              defer = $q.defer();
              Storage.categoryChains('get').then(function(chains) {
                return defer.resolve(chains);
              });
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
