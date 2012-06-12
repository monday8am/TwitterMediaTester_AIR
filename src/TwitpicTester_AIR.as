package
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
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
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	
	import services.UploadTwitPicOperation;
	
	
	
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
			upload_twitpic 	= new PushButton( this, 30, 60,  " Upload Twitpic ", onPressBtn );
			upload_twitter 	= new PushButton( this, 30, 90,  " Upload Twitter ", onPressBtn );
			loadImage_btn 	= new PushButton( this, 30, 120,  " Change Image   ", onPressBtn );
			label_events	= new TextArea( this, 150, 60, "logs... " ); label_events.width = 250; label_events.height = 211;
			
			
			// define twitter windows style
			
			windowOptions = new NativeWindowInitOptions();
			windowOptions.type = NativeWindowType.LIGHTWEIGHT;
			windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
			windowOptions.transparent = true;
			windowOptions.resizable = false;
			windowOptions.minimizable = false;		
			
			// create image data
			
			var picture : Bitmap = new Picture();
			addChild( picture );
			picture.x = 420;
			picture.y = 60;
			
			
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
		
		
		private function postInTwitter():void
		{
			tweetr.updateStatus( twitter_msg + " " + twitpic_url );
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
				
				// post in twit pic..
				
				uploadImageToTwitpic();
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
		
		private function onPressBtn():void
		{
			// TODO Auto Generated method stub
			
		}		
		
		private function log( str : String ):void
		{
			label_events.text += str + "\n";
		}
		
	}
}