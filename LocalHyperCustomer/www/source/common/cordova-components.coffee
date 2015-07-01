angular.module 'LocalHyper.common'


.factory 'CToast', ['$cordovaToast', 'App', ($cordovaToast, App)->

	CToast = {}

	CToast.show = (content)->
		if App.isWebView()
			$cordovaToast.showShortBottom content
		else
			console.log content

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

	CDialog.prompt = (message)->

	CDialog
]

