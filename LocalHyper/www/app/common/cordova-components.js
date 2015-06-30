angular.module('LocalHyper.common').factory('CToast', [
  '$cordovaToast', 'App', function($cordovaToast, App) {
    var CToast;
    CToast = {};
    CToast.show = function(content) {
      if (App.isWebView()) {
        return $cordovaToast.showShortBottom(content);
      } else {
        return console.log(content);
      }
    };
    return CToast;
  }
]).factory('CSpinner', [
  '$cordovaSpinnerDialog', 'App', function($cordovaSpinnerDialog, App) {
    var CSpinner, webview;
    CSpinner = {};
    webview = App.isWebView();
    CSpinner.show = function(title, message, persistent) {
      if (persistent == null) {
        persistent = true;
      }
      if (webview) {
        return $cordovaSpinnerDialog.show(title, message, persistent);
      } else {
        return console.log(message);
      }
    };
    CSpinner.hide = function() {
      if (webview) {
        return $cordovaSpinnerDialog.hide();
      }
    };
    return CSpinner;
  }
]).factory('CDialog', [
  '$cordovaDialogs', 'App', function($cordovaDialogs, App) {
    var CDialog;
    CDialog = {};
    CDialog.prompt = function(message) {};
    return CDialog;
  }
]).factory('CSms', [
  'App', '$q', function(App, $q) {
    var CSms, android, smsplugin, smspluginSrc;
    android = App.isAndroid();
    smspluginSrc = "info.asankan.phonegap.smsplugin.smsplugin";
    if (android) {
      smsplugin = cordova.require(smspluginSrc);
    }
    CSms = {};
    CSms.reception = function(action) {
      var defer, onError, onSuccess;
      defer = $q.defer();
      onSuccess = function(result) {
        return defer.resolve(result);
      };
      onError = function(error) {
        return defer.reject(error);
      };
      if (android) {
        switch (action) {
          case 'start':
            smsplugin.startReception(onSuccess, onError);
            break;
          case 'stop':
            smsplugin.stopReception(onSuccess, onError);
            break;
          default:
            defer.resolve('Invalid action');
        }
      } else {
        defer.resolve();
      }
      return defer.promise;
    };
    return CSms;
  }
]);
