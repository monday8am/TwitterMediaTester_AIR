package
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	
	import file.JPEGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import ru.inspirit.net.MultipartURLLoader;
	
	
	
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
			oauth.htmlLoader = htmlLoader;				

			oauth.getAuthorizationRequest();
			
			log( "Tweetr and OAuth initialized" );
			log( "Get authorization request" )
			
		}	
		

		private function postMediaToTwitter():void
		{
			// create file data
			
			var myEncoder : JPEGEncoder = new JPEGEncoder( 80);
			var byteArray : ByteArray = myEncoder.encode( image_data );		
			
			// get credentials
			
			var signedData:String  = oauth.getSignedRequest( URLRequestMethod.POST, "https://upload.twitter.com/1/statuses/update_with_media.json", null );
			var headerValue : String = createAuthorizationHeader( new URLVariables( signedData ) );
			
			// create multipart loader
			
			var multipar_loader : MultipartURLLoader = new MultipartURLLoader();
			multipar_loader.addEventListener( Event.COMPLETE, handleUploadComplete );	
			multipar_loader.addEventListener( IOErrorEvent.IO_ERROR, onError );
			multipar_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );				
			
			// add headers
			
			var auth_header : URLRequestHeader = new URLRequestHeader( "Authorization", headerValue );
			multipar_loader.requestHeaders.push( auth_header );
			
			// add requeried data
			
			multipar_loader.addVariable( "status" , twitter_msg );
			multipar_loader.addFile( byteArray, 'image.jpg', 'media[]');		
			
			// load
			
			multipar_loader.load( "https://upload.twitter.com/1/statuses/update_with_media.json" );
		}	
		
		
		private function postMediaToTwitpic():void
		{
			// create file data
			
			var myEncoder : JPEGEncoder = new JPEGEncoder( 80);
			var byteArray : ByteArray = myEncoder.encode( image_data );		
			
			// get credentials
			
			var signedData:String  = oauth.getSignedRequest( URLRequestMethod.GET, "http://api.twitter.com/1/account/verify_credentials.json", null );
			var authHeaderValue : String = createAuthorizationHeader( new URLVariables( signedData ), "http://api.twitter.com/" );
			
			// create multipart loader
			
			var multipar_loader : MultipartURLLoader = new MultipartURLLoader();
			multipar_loader.addEventListener( Event.COMPLETE, handleUploadTwitpicComplete );	
			multipar_loader.addEventListener( IOErrorEvent.IO_ERROR, onError );
			multipar_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );					
			
			// add headers
			
			multipar_loader.requestHeaders.push( new URLRequestHeader( "X-Verify-Credentials-Authorization", authHeaderValue ) );
			multipar_loader.requestHeaders.push( new URLRequestHeader( "X-Auth-Service-Provider", "http://api.twitter.com/1/account/verify_credentials.json" ) );
			
			// add requeried data
			
			multipar_loader.addVariable( "key" , "cd887da0d073a83989b3df8fc0c4bd54" );
			multipar_loader.addVariable( "message" , twitter_msg );
			multipar_loader.addFile( byteArray, 'image.jpg', 'media');		
			
			// load
			
			multipar_loader.load( "http://api.twitpic.com/2/upload.json" );	
			
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
				
				log( "OAuth login successfull" );
				log( "OAuth Token: " 	  + oauth.oauthToken);
				log( "OAuth TokenSecret: " + oauth.oauthTokenSecret );		
			}
			
			if (event.type == OAuthEvent.ERROR )
			{
				log( "OAuth login error" );
				log( "OAuthEvent.ERROR :" + event.type.toLocaleUpperCase() );
			}
			
			oauth.removeEventListener( OAuthEvent.COMPLETE, handleOAuthEvent);
			oauth.removeEventListener( OAuthEvent.ERROR   , handleOAuthEvent);			
		}	
		
		
		private function handleLocationChange( e : Event ):void
		{
				
		}	
		
		
		private function handleUploadTwitpicComplete( event : Event ):void
		{ 

			log( "Image shared on twitpic" );
			log( "Server response:" );
			var serverResponse : String = MultipartURLLoader( event.currentTarget).loader.data;
			log( serverResponse );
			
			var data : Object = JSON.parse( serverResponse );
			if( data.url != null )
			{
				twitpic_url = data.url as String;
				log( "Twitpic URL:" + twitpic_url );
			}
			
			// share url on twitter
			
			postInTwitter();			
		}		
		
		private function handleUploadComplete( event:Event):void
		{
			log( "Image shared on twitter" );
			log( "Server response:" );
			log( MultipartURLLoader( event.currentTarget).loader.data );
		}			
		
		
		private function onError( event : ErrorEvent ):void
		{
			log( "Error uploading image" );
			log( "Error ID: " + event.errorID );
			log( "Error text: " + event.text );
			log( MultipartURLLoader( event.currentTarget).loader.data );
		}
		
		
		private function onPressBtn( e : MouseEvent ):void
		{
			if( e.currentTarget == login_btn )
			{
				loginOnTwitter();
			}
			
			if( e.currentTarget == upload_twitpic )
			{
				postMediaToTwitpic();
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
		
		

		/**
		 * 
		 *  Utils
		 * 
		 */
		
		private function log( str : String ):void
		{
			label_events.text += str + "\n";
		}
		
		
		private function createAuthorizationHeader( _requestParams : Object, headerRealm : String = "" ) : String
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