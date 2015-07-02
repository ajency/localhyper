package org.apache.cordova.core;

import android.app.Application;
import android.content.Context;

import com.parse.Parse;
import com.parse.ParseInstallation;
import com.parse.PushService;

import com.local.hyper.alpha.MainActivity;

public class ParseApplication extends Application 
{
	private static ParseApplication instance = new ParseApplication();

	public ParseApplication() {
		instance = this;
	}

	public static Context getContext() {
		return instance;
	}

	@Override
	public void onCreate() {
		super.onCreate();
		
		Parse.initialize(this, "QN2IxFFiHCTm0oKSgI6KafqJJQ3nAxwQD8QiqrYZ", "Ns8Fx0RTUY7qfaZ16Mhm8XMb0dNVnlhx9Xjrz8OA");
		PushService.setDefaultPushCallback(this, MainActivity.class);
		ParseInstallation.getCurrentInstallation().saveInBackground();
	}
}
