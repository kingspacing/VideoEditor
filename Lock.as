package com.editor.controller.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	public class Lock extends Object
	{
		public function Lock()
		{
			
		}
		
		public static function lock(param:*):void
		{
			if (param is DisplayObjectContainer)
			{
				param.mouseEnabled = false;
				param.mouseChildren = false;
				param.useHandCursor = false;
			}
			else
			{
				param.mouseEnabled = false;
			}
		}
		
		public static function unlock(param:*):void
		{
			if (param is DisplayObjectContainer)
			{
				param.mouseEnabled = true;
				param.mouseChildren = true;
				param.useHandCursor = true;
			}
			else
			{
				param.mouseEnabled = true;
			}
		}
	}
}
