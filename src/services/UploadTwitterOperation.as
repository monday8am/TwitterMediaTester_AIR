package services
{
	import file.JPEGEncoder;
	import file.UploadPostHelper;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import ru.inspirit.net.MultipartURLLoader;
	
	public class UploadTwitterOperation extends Operation
	{
		
		private var GATEWAY_URL : String;
		private var urlRequest : URLRequest;
		private var urlLoader : URLLoader;
		
		private var image_data : BitmapData;
		private var extra_params : Object;
		public  var url_result : String;
		private var signedData : String;
		
		
		public function UploadTwitterOperation( image_data : BitmapData, extra_params : Object, signedData : String  )
		{
			super();
			this.image_data = image_data;
			this.extra_params = extra_params;
			this.signedData = signedData; 
		}
		
		
		override public function execute() : void
		{
			
			var myEncoder : JPEGEncoder = new JPEGEncoder( 80);
			var byteArray : ByteArray = myEncoder.encode( image_data );
			
			
			var multipar_loader : MultipartURLLoader = new MultipartURLLoader();
			
			multipar_loader.addEventListener( Event.COMPLETE, handleComplete);
			multipar_loader.addEventListener( IOErrorEvent.IO_ERROR, onImageCreationError );
			multipar_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onImageCreationError );			
			
			
			// add variables
			multipar_loader.setAuthHeaders( signedData );
			
			/**/
			for (var nameValue : String in extra_params )
			{
				multipar_loader.addVariable( nameValue, extra_params[ nameValue] );
			}
			
			// add file
			
			multipar_loader.addFile( byteArray, 'image.jpg', 'media[]');		
			
			// load
			
			multipar_loader.load( "https://upload.twitter.com/1/statuses/update_with_media.json" );
		}
		
		
		/*
		* 
		* Handler
		* 
		*/
		override protected function handleComplete( e: Object ):void
		{
			var data : Object = JSON.parse( urlLoader.data  );
			if( data.url != null )
			{
				trace( data.url );
				this.url_result = data.url as String;
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function onImageCreationError(event:Event):void 
		{
			handleFault(event);
		}			
		
	}
}