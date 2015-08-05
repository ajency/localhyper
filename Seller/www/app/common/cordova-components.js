angular.module('LocalHyper.common').factory('CToast', [
  '$cordovaToast', 'App', function($cordovaToast, App) {
    var CToast, webview;
    CToast = {};
    webview = App.isWebView();
    CToast.show = function(content) {
      if (webview) {
        return $cordovaToast.showShortBottom(content);
      } else {
        return console.log(content);
      }
    };
    CToast.showLongBottom = function(content) {
      if (webview) {
        return $cordovaToast.showLongBottom(content);
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
    CDialog.confirm = function(title, message, buttons) {
      return $cordovaDialogs.confirm(message, title, buttons);
    };
    return CDialog;
  }
]);
