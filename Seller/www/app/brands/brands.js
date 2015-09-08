angular.module('LocalHyper.brands', []).controller('BrandsCtrl', [
  '$scope', 'BrandsAPI', '$stateParams', 'SubCategory', 'CToast', 'CategoriesAPI', 'App', 'CDialog', 'Storage', 'User', function($scope, BrandsAPI, $stateParams, SubCategory, CToast, CategoriesAPI, App, CDialog, Storage, User) {
    $scope.view = {
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
        this.brands = data;
        return this.setBrandSelection();
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getBrands();
      },
      isCategoryChainsEmpty: function() {
        var empty;
        this.categoryChains = CategoriesAPI.categoryChains('get');
        empty = _.isEmpty(this.categoryChains);
        return empty;
      },
      setBrandSelection: function() {
        var _brandIds, _brands, chain;
        if (this.isCategoryChainsEmpty()) {
          _.each(this.brands, function(brand) {
            return brand.selected = false;
          });
        } else {
          chain = _.filter(this.categoryChains, function(chains) {
            return chains.subCategory.id === SubCategory.id;
          });
          if (!_.isEmpty(chain)) {
            _brands = chain[0].brands;
            _brandIds = _.pluck(_brands, 'objectId');
            _.each(this.brands, function(brand) {
              return brand.selected = _.contains(_brandIds, brand.objectId);
            });
          } else {
            _.each(this.brands, function(brand) {
              return brand.selected = false;
            });
          }
        }
        return this.setSelectAll();
      },
      setSelectAll: function() {
        var selected;
        selected = _.pluck(this.brands, 'selected');
        return this.selectAll = !_.contains(selected, false);
      },
      onSelectAll: function() {
        this.selectAll = !this.selectAll;
        if (this.selectAll) {
          return _.each(this.brands, function(brand) {
            return brand.selected = true;
          });
        } else {
          return _.each(this.brands, function(brand) {
            return brand.selected = false;
          });
        }
      },
      onDone: function() {
        return CategoriesAPI.getAll().then((function(_this) {
          return function(allCategories) {
            var chain, chainIndex, data, minOneBrandSelected, parentCategory, selectedBrands;
            parentCategory = _.filter(allCategories.data, function(category) {
              return category.id === SubCategory.parent;
            });
            selectedBrands = _.filter(_this.brands, function(brand) {
              return brand.selected === true;
            });
            minOneBrandSelected = _.size(selectedBrands) === 0 ? false : true;
            data = [];
            chain = {
              category: parentCategory[0],
              subCategory: SubCategory,
              brands: selectedBrands
            };
            data.push(chain);
            if (_this.isCategoryChainsEmpty()) {
              _this.categoryChains = minOneBrandSelected ? data : [];
            } else {
              chainIndex = _.findIndex(_this.categoryChains, function(chains) {
                return chains.subCategory.id === SubCategory.id;
              });
              if (chainIndex !== -1) {
                if (minOneBrandSelected) {
                  _this.categoryChains[chainIndex].brands = selectedBrands;
                } else {
                  _this.categoryChains.splice(chainIndex, 1);
                }
              }
              if (chainIndex === -1 && minOneBrandSelected) {
                _this.categoryChains.push(chain);
              }
            }
            if (!minOneBrandSelected) {
              return CDialog.confirm('Select Brands', 'You have not selected any brands', ['Continue', 'Cancel']).then(function(btnIndex) {
                if (btnIndex === 1) {
                  return _this.beforeGoBack();
                }
              });
            } else {
              return _this.beforeGoBack();
            }
          };
        })(this));
      },
      beforeGoBack: function() {
        if (User.isLoggedIn()) {
          CategoriesAPI.categoryChains('set', this.categoryChains);
          return this.goBack();
        } else {
          CategoriesAPI.categoryChains('set', this.categoryChains);
          return Storage.categoryChains('set', this.categoryChains).then((function(_this) {
            return function() {
              return _this.goBack();
            };
          })(this));
        }
      },
      goBack: function() {
        var count;
        switch (App.previousState) {
          case 'categories':
            count = -2;
            break;
          case 'sub-categories':
            count = -3;
            break;
          case 'category-chains':
            count = -1;
            break;
          case 'my-profile':
            count = -1;
            break;
          default:
            count = 0;
        }
        return App.goBack(count);
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function() {
      $scope.view.selectAll = false;
      if ($scope.view.display === 'noError') {
        return $scope.view.setBrandSelection();
      }
    });
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
