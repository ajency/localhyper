angular.module('LocalHyper.profile', []).controller('ProfileCtrl', [
  '$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI', function($scope, User, App, CToast, Storage, CategoriesAPI) {
    var user;
    user = User.getCurrent();
    console.log(user);
    return $scope.view = {
      showDelete: false,
      categoryChains: [],
      setCategoryChains: function() {
        return Storage.categoryChains('get').then((function(_this) {
          return function(chains) {
            console.log(chains);
            if (!_.isNull(chains)) {
              _this.categoryChains = chains;
              return CategoriesAPI.categoryChains('set', chains);
            }
          };
        })(this));
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
        this.categoryChains.splice(spliceIndex, 1);
        CategoriesAPI.categoryChains('set', this.categoryChains);
        return Storage.categoryChains('set', this.categoryChains);
      }
    };
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
          templateUrl: 'views/profile/profile.html'
        }
      }
    });
  }
]);
