package com.editor.service
{
	import com.editor.controller.signals.LoadVideoURLXMLFailedSignal;
	import com.editor.controller.signals.SetVideoURLSignal;
	import com.editor.controller.signals.UpdatePlayButtonStateSignal;
	import com.editor.controller.utils.Config;
	import com.editor.controller.utils.VideoConfig;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class VideoService
	{
		[Inject]
		public var setVideoURLSignal:SetVideoURLSignal;
		
		[Inject]
		public var  updatePlayButtonStateSignal:UpdatePlayButtonStateSignal;
		
		[Inject]
		public var loadVideoURLXMLFailedSignal:LoadVideoURLXMLFailedSignal
		
		
		private var _request:URLRequest;
		private var _loader:URLLoader;
		private var _url:Array = new Array();
		//private var _videoURL:String = Config.getInstance().VideoURL;
		
		public function VideoService()
		{
			
		}
		
		public function getVideoURL():void  
		{
			var _XML_URL:String = "resource/config/video.xml";    
			_request = new URLRequest(_XML_URL);
			_loader = new URLLoader();
			_loader.load(_request);
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			trace ("VideoService SercurityError:" + event);
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			trace ("加载百分比:" + String((event.bytesLoaded / event.bytesTotal ) * 100) + "%");
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
			trace("VideoService IOError:" + event);
			loadVideoURLXMLFailedSignal.dispatch();
		}
		
		protected function onComplete(event:Event):void
		{
			var xml:XML = new XML(_loader.data);
			parseXML(xml);
		}		
		
		protected function parseXML(xml:XML):void
		{
			try
			{
				for each (var video:XML in xml.video)
				{
					var o:Object = new Object();
					o.id = video.@id.toString();
					o.url = video.@url.toString();
					o.name = video.@name.toString();
					url.push(o);
				}
			}
			catch (e:Error)
			{
				trace ("parseXML:" + e.message);
				loadVideoURLXMLFailedSignal.dispatch();//解析或加载影片地址XMl文件出错，提示用户刷新页面重试
			}
			setVideoURLSignal.dispatch(url); //发送到videoplayer, 
			updatePlayButtonStateSignal.dispatch(url);//发送到mainview，更新播放按钮状态
			
			//可以使用单例模式不需要signal,如下
			//VideoConfig.getIntance().videoURL = url;
		}
		
		public function get url():Array
		{
			return _url;
		}
		
		public function set url(value:Array):void
		{
			_url = value;
		}

	}
}
