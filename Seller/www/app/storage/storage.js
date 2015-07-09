angular.module('LocalHyper.storage', []).factory('Storage', [
  function() {
    var Storage;
    Storage = {};
    Storage.slideTutorial = function(action) {
      switch (action) {
        case 'set':
          return localforage.setItem('app_tutorial_seen', true);
        case 'get':
          return localforage.getItem('app_tutorial_seen');
      }
    };
    return Storage;
  }
]);
