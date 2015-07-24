package com.plugin.gcm;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gcm.GCMBaseIntentService;

@SuppressLint("NewApi")
public class GCMIntentService extends GCMBaseIntentService {

	private static final String TAG = "GCMIntentService";
	
	public GCMIntentService() {
		super("GCMIntentService");
	}

	@Override
	public void onRegistered(Context context, String regId) {

		Log.v(TAG, "onRegistered: "+ regId);

		JSONObject json;

		try
		{
			json = new JSONObject().put("event", "registered");
			json.put("regid", regId);

			Log.v(TAG, "onRegistered: " + json.toString());

			// Send this JSON data to the JavaScript application above EVENT should be set to the msg type
			// In this case this is the registration ID
			PushPlugin.sendJavascript( json );

		}
		catch( JSONException e)
		{
			// No message to the user is sent, JSON failed
			Log.e(TAG, "onRegistered: JSON exception");
		}
	}

	@Override
	public void onUnregistered(Context context, String regId) {
		Log.d(TAG, "onUnregistered - regId: " + regId);
	}

	@Override
	protected void onMessage(Context context, Intent intent) {
		Log.d(TAG, "onMessage - context: " + context);
		
		Bundle extras = intent.getExtras();
		if (extras != null)
		{
			try{
	            if (PushPlugin.isInForeground()) {
					extras.putBoolean("foreground", true);
				}
				else {
					extras.putBoolean("foreground", false);
		            try {
						JSONObject extrasJson = new JSONObject(extras.get("data").toString());
						//Send a notification if there is a header and message
			            if (extrasJson.getString("header") != null && extrasJson.getString("message") != null)
			            	createNotification(context, extras, extrasJson);
			            else
			            	Log.d("PARSE PUSH", "Invalid Payload");
					} 
		            catch (JSONException e) {
						Log.e("JSON NOTIFICATION ERROR", "onMessage");
					}
				}
	            
	            PushPlugin.sendExtras(extras);
			}
			catch(Exception e){
				Log.e("PushPlugin instance error", "onMessage");
			}
        }
	}

	public void createNotification(Context context, Bundle extras, JSONObject extrasJson)
	{	
		try{
			NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
			String appName = getAppName(this);
	
			Intent notificationIntent = new Intent(this, PushHandlerActivity.class);
			notificationIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
			notificationIntent.putExtra("pushBundle", extras);
			
			int notId = getNotificationID();
			setNotificationID(notId + 1);
			
			PendingIntent contentIntent = PendingIntent.getActivity(this, notId, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);
			
			//Common fields
			NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(context)
				.setDefaults(Notification.DEFAULT_ALL)
				.setSmallIcon(context.getApplicationInfo().icon)
				.setWhen(System.currentTimeMillis())
				.setContentIntent(contentIntent)
				.setAutoCancel(true);
				
			String title = extrasJson.getString("header");
			String alert = extrasJson.getString("message");
			mBuilder
				.setContentTitle(title)
				.setTicker(title)
				.setContentText(alert)
				.setStyle(new NotificationCompat.BigTextStyle().bigText(alert));
			
			mNotificationManager.notify((String) appName, notId, mBuilder.build());
		}
			
		catch(JSONException e){
			Log.e("JSON NOTIFICATION ERROR", "createNotification");
		}
	}
	
	public int getNotificationID(){
		SharedPreferences pref = getSharedPreferences("ApplicationPrefs", 0);
		int id = pref.getInt("app_notification_id", 0);
		return id;
	}
	
	public void setNotificationID(int id){
		SharedPreferences pref = getSharedPreferences("ApplicationPrefs", 0);
		SharedPreferences.Editor editor = pref.edit();
		editor.putInt("app_notification_id", id);
	    editor.commit();
	}
	
	private static String getAppName(Context context)
	{
		CharSequence appName = 
				context
					.getPackageManager()
					.getApplicationLabel(context.getApplicationInfo());
		
		return (String)appName;
	}
	
	@Override
	public void onError(Context context, String errorId) {
		Log.e(TAG, "onError - errorId: " + errorId);
	}

}
