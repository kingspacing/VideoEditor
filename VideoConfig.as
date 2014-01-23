package com.editor.controller.utils
{
	import mx.core.Singleton;

	public class VideoConfig
	{
		private static var _instance:VideoConfig;
		private var _videoURL:Array;

		public function VideoConfig(singleton:Singleton)
		{
			if (singleton == null)
			{
				throw new Error("单例模式不允许用构造函数实例化");
			}
		}
		
		public static function getIntance():VideoConfig
		{
			if (_instance == null)
			{
				_instance = new VideoConfig(new Singleton());
			}
			return _instance;
		}

		public function get videoURL():Array
		{
			return _videoURL;
		}

		public function set videoURL(value:Array):void
		{
			_videoURL = value;
		}

	}
}
internal class Singleton
{
	
}
