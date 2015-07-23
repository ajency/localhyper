angular.module('LocalHyper.BussinessDetailStorage', []).factory('BussinessDetailStorage', [
  function() {
    var BussinessStorage;
    BussinessStorage = {};
    Storage.slideTutorial = function(action) {
      switch (action) {
        case 'set':
          return localforage.setItem('app_tutorial_seen', true);
        case 'get':
          return localforage.getItem('app_tutorial_seen');
      }
    };
    return BussinessStorage;
  }
]);
