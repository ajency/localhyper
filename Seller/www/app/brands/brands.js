angular.module('LocalHyper.brands', []).controller('BrandsCtrl', [
  '$scope', 'BrandsAPI', '$stateParams', 'SubCategory', 'CToast', 'CategoriesAPI', 'App', function($scope, BrandsAPI, $stateParams, SubCategory, CToast, CategoriesAPI, App) {
    return $scope.view = {
      title: SubCategory.name,
      brands: [],
      display: 'loader',
      errorType: '',
      categoryChains: null,
      init: function() {
        return this.getBrands();
      },
      getBrands: function() {
        return BrandsAPI.getAll($stateParams.categoryID).then((function(_this) {
          return function(data) {
            console.log(data);
            return _this.onSuccess(data.supported_brands);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this));
      },
      onSuccess: function(data) {
        this.display = 'noError';
        return this.brands = data;
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getBrands();
      },
      onDone: function() {
        var atleastOneSelected;
        atleastOneSelected = false;
        _.each(this.brands, function(brand) {
          if (brand.selected) {
            return atleastOneSelected = true;
          }
        });
        this.categoryChains = CategoriesAPI.categoryChains('get');
        if (_.isEmpty(this.categoryChains)) {
          if (!atleastOneSelected) {
            return CToast.show('Please select atleast one brand');
          } else {
            return this.setCategoryChains(true);
          }
        } else {
          return this.setCategoryChains(false);
        }
      },
      setCategoryChains: function(empty) {
        return CategoriesAPI.getAll().then((function(_this) {
          return function(allCategories) {
            var chain, data, existingChain, parentCategory, selectedBrands;
            parentCategory = _.filter(allCategories, function(category) {
              return category.id === SubCategory.parent;
            });
            selectedBrands = _.filter(_this.brands, function(brand) {
              return brand.selected === true;
            });
            data = [];
            chain = {
              category: parentCategory[0],
              subCategory: SubCategory,
              brands: selectedBrands
            };
            data.push(chain);
            if (empty) {
              CategoriesAPI.categoryChains('set', data);
            } else {
              existingChain = false;
              _.each(_this.categoryChains, function(chains, index) {
                if (chains.subCategory.id === SubCategory.id) {
                  existingChain = true;
                  return _this.categoryChains[index].brands = selectedBrands;
                }
              });
              if (!existingChain) {
                _this.categoryChains.push(chain);
              }
              CategoriesAPI.categoryChains('set', _this.categoryChains);
            }
            return App.navigate('category-chains');
          };
        })(this));
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('brands', {
      url: '/brands:categoryID',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/brands/brands.html',
          controller: 'BrandsCtrl',
          resolve: {
            SubCategory: function($stateParams, CategoriesAPI) {
              var childCategory, subCategories;
              subCategories = CategoriesAPI.subCategories('get');
              childCategory = _.filter(subCategories, function(category) {
                return category.id === $stateParams.categoryID;
              });
              return childCategory[0];
            }
          }
        }
      }
    });
  }
]);
