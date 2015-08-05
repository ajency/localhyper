angular.module('LocalHyper.profile', []).controller('ProfileCtrl', [
  '$q', '$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI', 'AuthAPI', 'CSpinner', 'CategoryChains', function($q, $scope, User, App, CToast, Storage, CategoriesAPI, AuthAPI, CSpinner, CategoryChains) {
    $scope.view = {
      showDelete: false,
      categoryChains: [],
      setCategoryChains: function() {
        this.categoryChains = CategoryChains;
        return CategoriesAPI.categoryChains('set', CategoryChains);
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
        var user;
        CSpinner.show('', 'Please wait...');
        CategoriesAPI.categoryChains('set', this.categoryChains);
        Storage.categoryChains('set', this.categoryChains);
        user = User.info('get');
        return AuthAPI.isExistingUser(user).then((function(_this) {
          return function(data) {
            return AuthAPI.loginExistingUser(data.userObj);
          };
        })(this)).then(function(success) {
          return App.navigate('new-requests');
        }, (function(_this) {
          return function(error) {
            return CToast.show('Please try again data not saved');
          };
        })(this))["finally"](function() {
          return CSpinner.hide();
        });
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
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
            }
          }
        }
      }
    });
  }
]);
