angular.module('LocalHyper.categories').controller('SubCategoriesCtrl', [
  '$scope', 'SubCategory', function($scope, SubCategory) {
    return $scope.view = {
      title: SubCategory.parentTitle,
      subCategories: SubCategory.data,
      imageSizes: SubCategory.imageSizes
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('sub-categories', {
      url: '/sub-categories:parentID',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/categories/sub-categories.html',
          controller: 'SubCategoriesCtrl',
          resolve: {
            SubCategory: function($stateParams, CategoriesAPI) {
              return CategoriesAPI.getAll().then(function(categories) {
                var children, parent, subCategory;
                parent = _.filter(categories.data, function(category) {
                  return category.id === $stateParams.parentID;
                });
                children = parent[0].children;
                CategoriesAPI.subCategories('set', children);
                return subCategory = {
                  parentTitle: parent[0].name,
                  data: children,
                  imageSizes: categories.imageSizes
                };
              });
            }
          }
        }
      }
    });
  }
]);
