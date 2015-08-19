angular.module 'LocalHyper.common'


.factory 'CToast', ['$cordovaToast', ($cordovaToast)->

	CToast = {}
	webview = ionic.Platform.isWebView()

	CToast.show = (content)->
		if webview then $cordovaToast.showShortBottom content
		else console.log content

	CToast.showLongBottom = (content)->
		if webview then $cordovaToast.showLongBottom content
		else console.log content

	CToast
]


.factory 'CSpinner', ['$cordovaSpinnerDialog', 'App', ($cordovaSpinnerDialog, App)->
	
	CSpinner = {}
	webview = App.isWebView()

	CSpinner.show = (title, message, persistent=true)->
		if webview then $cordovaSpinnerDialog.show title, message, persistent
		else console.log message

	CSpinner.hide = ->
		$cordovaSpinnerDialog.hide() if webview

	CSpinner
]


.factory 'CDialog', ['$cordovaDialogs', 'App', ($cordovaDialogs, App)->
	
	CDialog = {}

	CDialog.confirm = (title, message, buttons)->
		$cordovaDialogs.confirm message, title, buttons

	CDialog
]



