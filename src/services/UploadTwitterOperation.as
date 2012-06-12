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
	
	public class UploadTwitterOperation extends Operation
	{
		
		private var GATEWAY_URL : String;
		private var urlRequest : URLRequest;
		private var urlLoader : URLLoader;
		
		private var image_data : BitmapData;
		private var extra_params : Object;
		public var url_result : String;
		
		
		public function UploadTwitterOperation( image_data : BitmapData, extra_params : Object )
		{
			super();
			this.image_data = image_data;
			this.extra_params = extra_params;
		}
		
		
		override public function execute() : void
		{
			
			var myEncoder : JPEGEncoder = new JPEGEncoder( 80);
			var byteArray : ByteArray = myEncoder.encode( image_data );
			
			urlRequest = new URLRequest( "https://upload.twitter.com/1/statuses/update_with_media.format" );
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			urlRequest.data = UploadPostHelper.getPostData( "media", byteArray, extra_params );
			urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
			
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener( Event.COMPLETE, handleComplete );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onImageCreationError );
			urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onImageCreationError );
			
			urlLoader.load( urlRequest );	
		}
		
		private function onImageCreationError(event:Event):void 
		{
			handleFault(event);
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
		
	}
}