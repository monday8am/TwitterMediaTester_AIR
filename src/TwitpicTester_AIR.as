package
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import services.UploadTwitPicOperation;
	import services.UploadTwitterOperation;
	
	
	
	[ SWF(backgroundColor="#ffffff", frameRate="24", width="700", height="300")]
	public class TwitpicTester_AIR extends Sprite
	{
		
		// twitter related
		
		private var tweetr 		 : Tweetr;
		private var oauth 		 : OAuth;
		private var twitter_msg  : String = "Testing twitpic service!";
		private var twitpic_url	 : String;
		
		
		// twitter window
		
		private var htmlLoader  	: HTMLLoader;	
		private var windowOptions	: NativeWindowInitOptions;
		
		
		// interface
		
		private var label				: Label;
		private var loadImage_btn 		: PushButton;
		private var login_btn	 		: PushButton;
		private var logout_btn	 		: PushButton;
		private var upload_twitpic 		: PushButton;
		private var upload_twitter 		: PushButton;
		private var label_events    	: TextArea;
		private var image_container     : Sprite = new Sprite();
		private var image_data		    : BitmapData; 	
		
		[Embed(source="picture.jpg")]
		private var Picture				: Class;
		
		
		
		public function TwitpicTester_AIR()
		{
			// interface 
			
			label 			= new Label		( this, 30, 30, "Testing upload service " );
			login_btn       = new PushButton( this, 30, 60,  " Login ", onPressBtn );
			upload_twitpic 	= new PushButton( this, 30, 90,  " Upload Twitpic ", onPressBtn );
			upload_twitter 	= new PushButton( this, 30, 120,  " Upload Twitter ", onPressBtn );
			loadImage_btn 	= new PushButton( this, 30, 150,  " Change Image   ", onPressBtn );
			logout_btn      = new PushButton( this, 30, 180,  " Logout ", onPressBtn );
			label_events	= new TextArea( this, 150, 60, "logs... " ); label_events.width = 250; label_events.height = 211;
			
			
			// define twitter windows style
			
			windowOptions = new NativeWindowInitOptions();
			windowOptions.type = NativeWindowType.NORMAL;
			windowOptions.systemChrome = NativeWindowSystemChrome.STANDARD;
			windowOptions.transparent = false;
			windowOptions.resizable = false;
			windowOptions.minimizable = false;		
			
			
			// create image data
			
			var picture : Bitmap = new Picture();
			addChild( picture );
			picture.x = 420;
			picture.y = 60;
			image_data = new BitmapData( picture.width, picture.height, false, 0xffffff );
			image_data.draw( picture );
			
			
		}
		
		
		public function loginOnTwitter():void
		{
			// create objects
			
			tweetr = new Tweetr();
			oauth = new OAuth();
			
			// app data
			
			oauth.consumerKey 	 = "EgorZrtAG41qyHD4oYk0sw";
			oauth.consumerSecret = "HbNexxZUDmM34oYL5B4aSVMLJnJJdojMXLssc0g3o";
			oauth.callbackURL 	 = "http://www.monday8am.com";
			oauth.pinlessAuth = true;
			
			oauth.addEventListener( OAuthEvent.COMPLETE, handleOAuthEvent );
			oauth.addEventListener( OAuthEvent.ERROR,    handleOAuthEvent );			
			
			htmlLoader = HTMLLoader.createRootWindow(  true, windowOptions, false, new Rectangle( 610, 78, 780, 480) );
			htmlLoader.paintsDefaultBackground = false;
			htmlLoader.stage.nativeWindow.alwaysInFront = true;
			htmlLoader.addEventListener( Event.LOCATION_CHANGE, handleLocationChange );
			
			// get  oauthToken
			
			oauth.htmlLoader = htmlLoader;
			oauth.getAuthorizationRequest();
			
		}	
		

		private function uploadImageToTwitpic():void
		{
			
			tweetr.updateStatus( "Testing more tweets :D :D" ); 
			return;			
			
			var params : Object = new Object();
			
			params.consumer_token  = oauth.consumerKey;      // twitter Consumer Token.
			params.consumer_secret = oauth.consumerSecret;   // twitter Consumer Secret.
			params.oauth_token     = oauth.oauthToken; 		 // the Twitter OAuth Token for the user.
			params.oauth_secret    = oauth.oauthTokenSecret; // the Twitter OAuth Secret for the user.
			params.message         = twitter_msg;
			
			params.key = "cd887da0d073a83989b3df8fc0c4bd54"; // (Required): Your API Key.
			
			var c : UploadTwitPicOperation = new UploadTwitPicOperation( image_data, params );
			c.addEventListener( Event.COMPLETE, onCompleteUploadImage );
			c.execute();	
			
		}	
		
		
		private function postMediaToTwitter():void
		{

			var params : Object = new Object();
			var signedData:String  = oauth.getSignedRequest( URLRequestMethod.POST, 
															 "https://upload.twitter.com/1/statuses/update_with_media.json", 
															  null );
			
			var url_vars : URLVariables = new URLVariables( signedData );
			url_vars.status = twitter_msg;	
			
			//OAuth oauth_consumer_key="mbmuCGVFTGHZOo5zr5Sx5A", oauth_nonce="f9685243ba64308204b1c14a05950b09", oauth_signature="LX%2BcnRvzT5Rm%2BYkPzdhX6I%2Bt9oo%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1313443626", oauth_token="119476949-KQjqYB1QCSC9ZtaTI8RRDDRJdSgk8hMcT4BJMEWi", oauth_version="1.0"			
			var headers : String = createHeaders( url_vars );
			
			var c : UploadTwitterOperation = new UploadTwitterOperation( image_data, url_vars, headers );
			c.addEventListener( Event.COMPLETE, onCompleteUploadImage );
			c.execute();
		}			
		
		
		private function postInTwitter():void
		{
			tweetr.updateStatus( twitter_msg + " " + twitpic_url );
		}		
		
		
		private function logoutFromTwitter():void
		{
			tweetr.endSession();
		}
		
		
		/**
		 *  Events handlers
		 * 
		 */  
			
		private function handleOAuthEvent(event:OAuthEvent):void
		{
			
			if (event.type == OAuthEvent.COMPLETE )
			{
				htmlLoader.stage.nativeWindow.close();
				tweetr.oAuth = oauth;
			}
			
			if (event.type == OAuthEvent.ERROR )
			{
				trace( "OauthEvent.ERROR :" + event.type.toLocaleUpperCase() );
			}
			
			oauth.removeEventListener( OAuthEvent.COMPLETE, handleOAuthEvent);
			oauth.removeEventListener( OAuthEvent.ERROR   , handleOAuthEvent);			
		}	
		
		
		private function onCompleteUploadImage(event:Event):void
		{
			var c : UploadTwitPicOperation = event.currentTarget as UploadTwitPicOperation;
			
			if( c.url_result != null )
			{
				twitpic_url =  c.url_result;
			}
			
			// share url on twitter
			
			postInTwitter();			
		}
		
		
		private function handleLocationChange( e : Event ):void
		{
				
		}	
		
		
		private function onPressBtn( e : MouseEvent ):void
		{
			if( e.currentTarget == login_btn )
			{
				loginOnTwitter();
			}
			
			if( e.currentTarget == upload_twitpic )
			{
				uploadImageToTwitpic();
			}
			
			if( e.currentTarget == upload_twitter )
			{
				postMediaToTwitter();
			}			
			
			if( e.currentTarget == logout_btn )
			{
				logoutFromTwitter();
			}				
			
		}		
		
		
		private function log( str : String ):void
		{
			label_events.text += str + "\n";
		}
		
		
		private function createHeaders( _requestParams : Object, headerRealm : String = "" ) : String
		{
			var data:String = "";
			
			data += "OAuth "
			if ( headerRealm.length > 0)
				data += "realm=\"" + headerRealm + "\", ";
			
			for (var param : Object in _requestParams ) {
				// if this is an oauth param, include it
				if ( param.toString().indexOf("oauth") == 0) 
				{
					data += param + "=\"" + encodeURIComponent( _requestParams[param]) + "\", ";
				}
			}
			
			return data.substr( 0, data.length - 2);
		}
		
	}
}