angular.module('LocalHyper.products', []).controller('ProductsCtrl', [
  '$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal', '$timeout', 'App', 'CToast', 'UIMsg', '$ionicLoading', '$ionicPlatform', 'CDialog', 'PrimaryAttribute', function($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout, App, CToast, UIMsg, $ionicLoading, $ionicPlatform, CDialog, PrimaryAttribute) {
    var onDeviceBack;
    $scope.view = {
      title: Product.subCategoryTitle,
      primaryAttribute: PrimaryAttribute,
      footer: false,
      gotAllProducts: false,
      products: [],
      other: [],
      page: 0,
      canLoadMore: false,
      refresh: false,
      search: '',
      filter: {
        modal: null,
        attribute: 'brand',
        allAttributes: [],
        attrValues: {},
        originalValues: {},
        selectedFilters: {
          brands: [],
          price: [],
          otherFilters: {}
        },
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/products/filters.html', {
            scope: $scope,
            animation: 'slide-in-up',
            hardwareBackButtonClose: false
          }).then((function(_this) {
            return function(modal) {
              return _this.modal = modal;
            };
          })(this));
        },
        getPriceRange: function(priceRange) {
          var divideValue, firstDigit, i, increment, intervalValue, intervalValueCharacter, max, min, prices, range, _i, _ref;
          prices = [];
          min = priceRange[0];
          max = priceRange[1];
          range = max / min;
          divideValue = Math.round(range);
          if (divideValue > 1) {
            if (divideValue > 10) {
              divideValue = 10;
            }
            intervalValue = Math.round((max - min) / divideValue);
            if (intervalValue < min) {
              intervalValue = min;
            }
            intervalValueCharacter = intervalValue.toString();
            firstDigit = intervalValueCharacter.substring(0, 1);
            firstDigit = parseInt(firstDigit) + 1;
            firstDigit = firstDigit.toString();
            for (i = _i = 0, _ref = intervalValueCharacter.length - 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
              firstDigit += '0';
            }
            increment = parseInt(firstDigit);
            priceRange = _.range(0, max, increment);
            _.each(priceRange, function(start, index) {
              var end;
              end = priceRange[index + 1];
              if (_.isUndefined(end)) {
                end = start + increment;
              }
              if (start === 0) {
                return prices.push({
                  start: start,
                  end: end,
                  name: "Below - Rs " + end
                });
              } else {
                return prices.push({
                  start: start,
                  end: end,
                  name: "Rs " + start + " - Rs " + end
                });
              }
            });
          } else {
            max = (10 - max % 10) + max;
            prices.push({
              start: 0,
              end: max,
              name: "Below - Rs " + max
            });
          }
          return prices;
        },
        setAttrValues: function() {
          var other;
          other = $scope.view.other;
          this.attrValues['brand'] = other.supportedBrands;
          this.attrValues['price'] = this.getPriceRange(other.priceRange);
          this.allAttributes.push({
            value: 'brand',
            name: 'Brand',
            selected: 0
          });
          this.allAttributes.push({
            value: 'price',
            name: 'Price',
            selected: 0
          });
          _.each(other.filters, (function(_this) {
            return function(filter) {
              var value;
              value = filter.filterName;
              _this.attrValues[value] = filter.values;
              return _this.allAttributes.push({
                value: value,
                name: s.humanize(filter.attributeName),
                selected: 0
              });
            };
          })(this));
          return _.each(this.attrValues, function(values) {
            return _.each(values, function(val) {
              return val.selected = false;
            });
          });
        },
        showAttrCount: function() {
          return _.each(this.attrValues, (function(_this) {
            return function(values, index) {
              var attrIndex, count;
              count = 0;
              _.each(values, function(val) {
                if (val.selected) {
                  return count++;
                }
              });
              attrIndex = _.findIndex(_this.allAttributes, function(attrs) {
                return attrs.value === index;
              });
              return _this.allAttributes[attrIndex].selected = count;
            };
          })(this));
        },
        clearFilters: function() {
          _.each(this.attrValues, function(values) {
            return _.each(values, function(val) {
              return val.selected = false;
            });
          });
          _.each(this.allAttributes, function(attrs) {
            return attrs.selected = 0;
          });
          return this.selectedFilters = {
            brands: [],
            price: [],
            otherFilters: {}
          };
        },
        resetFilters: function() {
          this.attribute = 'brand';
          return this.clearFilters();
        },
        noChangeInSelection: function() {
          return _.isEqual(_.sortBy(this.originalValues), _.sortBy(this.attrValues));
        },
        openModal: function() {
          this.originalValues = JSON.parse(JSON.stringify(this.attrValues));
          return this.modal.show();
        },
        closeModal: function() {
          var msg;
          if (this.noChangeInSelection()) {
            return this.modal.hide();
          } else {
            msg = 'Your filter selection will go away';
            return CDialog.confirm('Exit Filter?', msg, ['Exit Anyway', 'Apply & Exit']).then((function(_this) {
              return function(btnIndex) {
                switch (btnIndex) {
                  case 1:
                    _this.attrValues = _this.originalValues;
                    _this.showAttrCount();
                    return _this.modal.hide();
                  case 2:
                    return _this.onApply();
                }
              };
            })(this));
          }
        },
        onApply: function() {
          _.each(this.attrValues, (function(_this) {
            return function(_values, attribute) {
              var end, selected, start;
              switch (attribute) {
                case 'price':
                  start = [];
                  end = [];
                  _.each(_values, function(price) {
                    if (price.selected) {
                      start.push(price.start);
                      return end.push(price.end);
                    }
                  });
                  if (_.isEmpty(start)) {
                    return _this.selectedFilters.price = [];
                  } else {
                    return _this.selectedFilters.price = [_.min(start), _.max(end)];
                  }
                  break;
                case 'brand':
                  selected = [];
                  _.each(_values, function(brand) {
                    if (brand.selected) {
                      return selected.push(brand.id);
                    }
                  });
                  return _this.selectedFilters.brands = selected;
                default:
                  selected = [];
                  _.each(_values, function(attr) {
                    if (attr.selected) {
                      return selected.push(attr.id);
                    }
                  });
                  return _this.selectedFilters.otherFilters[attribute] = selected;
              }
            };
          })(this));
          this.setExcerpt();
          this.modal.hide();
          return $scope.view.reFetch();
        },
        setExcerpt: function() {
          var filterNames;
          filterNames = [];
          _.each(this.allAttributes, (function(_this) {
            return function(attr, index) {
              if (attr.selected > 0) {
                return filterNames.push(attr.name);
              }
            };
          })(this));
          return this.excerpt = filterNames.join(', ');
        },
        isNotNA: function(name) {
          name = name.replace(/[^a-zA-Z ]/g, "");
          name = name.toLowerCase();
          return name !== 'na';
        },
        orderBy: function() {
          return function(obj) {
            var name;
            name = parseFloat(obj.name);
            if (_.isNaN(name)) {
              return obj.name;
            } else {
              return name;
            }
          };
        }
      },
      init: function() {
        return this.filter.loadModal();
      },
      beforeReset: function() {
        this.sortBy = 'popularity';
        this.sortName = 'Popularity';
        this.ascending = false;
        this.filter.excerpt = '';
        this.filter.resetFilters();
        this.pullToRefresh = false;
        return this.footer = false;
      },
      forSearch: function() {
        this.beforeReset();
        this.search = '';
        this.canLoadMore = false;
        return this.gotAllProducts = false;
      },
      reset: function() {
        this.beforeReset();
        return this.reFetch(false);
      },
      reFetch: function(refresh) {
        if (refresh == null) {
          refresh = true;
        }
        this.refresh = refresh;
        this.page = 0;
        this.products = [];
        this.canLoadMore = true;
        this.gotAllProducts = false;
        return this.onScrollComplete();
      },
      showSortOptions: function() {
        return $ionicLoading.show({
          scope: $scope,
          templateUrl: 'views/products/sort.html',
          hideOnStateChange: true
        });
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onRefreshComplete: function() {
        return $scope.$broadcast('scroll.refreshComplete');
      },
      onPullToRefresh: function() {
        if (App.isOnline()) {
          this.gotAllProducts = false;
          this.canLoadMore = false;
          this.page = 0;
          this.refresh = true;
          return this.getProducts();
        } else {
          this.onRefreshComplete();
          return CToast.show(UIMsg.noInternet);
        }
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.getProducts();
      },
      onSearch: function() {
        if (this.search === '') {
          return CToast.show('Please provide input');
        } else {
          return this.reFetch();
        }
      },
      getWordsFromSentence: function() {
        var sentence, stopWords, wordArr, words;
        wordArr = [];
        sentence = this.search;
        sentence = sentence.replace(/[^a-zA-Z0-9.]/g, " ");
        sentence = sentence.trim();
        wordArr = sentence.split(/\s+/g);
        wordArr = _.map(wordArr, function(word) {
          return word.toLowerCase();
        });
        wordArr = _.unique(wordArr);
        stopWords = ["the", "is", "and"];
        words = _.filter(wordArr, function(word) {
          return !_.contains(stopWords, word);
        });
        return words;
      },
      getSearchKeyWords: function() {
        if (App.currentState === 'products') {
          return 'all';
        } else {
          return this.getWordsFromSentence();
        }
      },
      getProducts: function() {
        var options;
        options = {
          categoryID: $stateParams.categoryID,
          page: this.page,
          sortBy: this.sortBy,
          ascending: this.ascending,
          selectedFilters: this.filter.selectedFilters,
          displayLimit: 24,
          searchKeywords: this.getSearchKeyWords()
        };
        return ProductsAPI.getAll(options).then((function(_this) {
          return function(data) {
            _this.onSuccess(data, options.displayLimit);
            return _this.footer = true;
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"]((function(_this) {
          return function() {
            _this.page = _this.page + 1;
            _this.pullToRefresh = true;
            _this.onRefreshComplete();
            return App.resize();
          };
        })(this));
      },
      onError: function(error) {
        CToast.showLong(UIMsg.serverError);
        return this.canLoadMore = false;
      },
      onSuccess: function(data, displayLimit) {
        var productsSize, _products;
        this.other = data;
        if (_.isEmpty(this.filter.attrValues['brand'])) {
          this.filter.setAttrValues();
        }
        _products = data.products;
        productsSize = _.size(_products);
        if (productsSize > 0) {
          if (productsSize < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            this.onScrollComplete();
          }
          if (this.refresh) {
            this.products = [];
            this.products = _products;
          } else {
            this.products = this.products.concat(_products);
          }
        } else {
          this.canLoadMore = false;
        }
        if (!this.canLoadMore) {
          return this.gotAllProducts = true;
        }
      },
      onSort: function(sortBy, sortName, ascending) {
        $ionicLoading.hide();
        switch (sortBy) {
          case 'popularity':
            if (this.sortBy !== 'popularity') {
              this.sortBy = 'popularity';
              this.sortName = sortName;
              this.ascending = ascending;
              return this.reFetch();
            }
            break;
          case 'mrp':
            if (this.sortBy !== 'mrp') {
              this.sortBy = 'mrp';
              this.sortName = sortName;
              this.ascending = ascending;
              return this.reFetch();
            } else if (this.ascending !== ascending) {
              this.sortBy = 'mrp';
              this.sortName = sortName;
              this.ascending = ascending;
              return this.reFetch();
            }
        }
      },
      onIonicLoadingHide: function() {
        return $ionicLoading.hide();
      }
    };
    onDeviceBack = function() {
      var filter;
      filter = $scope.view.filter;
      if ($('.loading-container').hasClass('visible')) {
        return $ionicLoading.hide();
      } else if (filter.modal.isShown()) {
        return filter.closeModal();
      } else {
        return App.goBack(-1);
      }
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      App.search.categoryID = $stateParams.categoryID;
      if (App.currentState === 'products-search') {
        $scope.view.forSearch();
        if (App.previousState !== 'single-product') {
          return $scope.view.products = [];
        }
      } else if (_.contains(['categories', 'sub-categories'], App.previousState)) {
        return $scope.view.reset();
      }
    });
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton(onDeviceBack);
    });
    return $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton(onDeviceBack);
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('products', {
      url: '/products:categoryID',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/products.html',
          controller: 'ProductsCtrl',
          resolve: {
            Product: function($stateParams, CategoriesAPI) {
              var childCategory, subCategories;
              subCategories = CategoriesAPI.subCategories('get');
              childCategory = _.filter(subCategories, function(category) {
                return category.id === $stateParams.categoryID;
              });
              return {
                subCategoryTitle: childCategory[0].name
              };
            }
          }
        }
      }
    }).state('products-search', {
      url: '/products-search:categoryID',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/products-search.html',
          controller: 'ProductsCtrl',
          resolve: {
            Product: function($stateParams, CategoriesAPI) {
              var childCategory, subCategories;
              subCategories = CategoriesAPI.subCategories('get');
              childCategory = _.filter(subCategories, function(category) {
                return category.id === $stateParams.categoryID;
              });
              return {
                subCategoryTitle: childCategory[0].name
              };
            }
          }
        }
      }
    });
  }
]);
