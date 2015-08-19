angular.module('LocalHyper.categories').controller('CategoryChainsCtrl', [
  '$scope', 'App', 'CategoriesAPI', 'Storage', 'CategoryChains', function($scope, App, CategoriesAPI, Storage, CategoryChains) {
    return $scope.view = {
      showDelete: false,
      categoryChains: [],
      init: function() {
        return this.setCategoryChains();
      },
      setCategoryChains: function() {
        if (!_.isNull(CategoryChains)) {
          this.categoryChains = CategoryChains;
          return CategoriesAPI.categoryChains('set', CategoryChains);
        }
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
        this.categoryChains.splice(spliceIndex, 1);
        CategoriesAPI.categoryChains('set', this.categoryChains);
        return Storage.categoryChains('set', this.categoryChains).then(function() {
          return App.resize();
        });
      },
      onChainClick: function(chains) {
        CategoriesAPI.subCategories('set', chains.category.children);
        return App.navigate('brands', {
          categoryID: chains.subCategory.id
        });
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('category-chains', {
      url: '/category-chains',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/categories/category-chains.html',
          controller: 'CategoryChainsCtrl',
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
