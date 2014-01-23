package com.editor.controller.utils
{
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import flash.display.DisplayObject;
	import flash.events.*;
	
	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function secondToTimeFomat(crrentTime:int) : String
		{
			var _hour:String = '';
			var _minute:String = '';
			var _second:String = '';
			
			_hour = String(100+Math.floor(crrentTime/3600)).substr(1,2);
			_minute = String(100+Math.floor(crrentTime/60) % 60).substr(1,2);
			_second = String(100+Math.floor(crrentTime%60)).substr(1,2);
			if(_hour!='00')
			{				
				
				return _hour +":"+_minute+":"+_second;
				
			}
			else
			{
				
				return "00:" + _minute+":"+_second;
			}
		}
		
		public static function fadeOut(target:DisplayObject):void
		{
			TweenLite.to(target, 1, {alpha:0});
		}
		
		public static function fadeIn(target:DisplayObject):void
		{
			TweenLite.to(target, 1, {alpha:1});
		}
		
		public static function hideShadow(target:Object):void 
		{
			TweenMax.to(target, 0.25, {dropShadowFilter:{color:0x33ff00, alpha:0, blurX:10, blurY:10}});
		}
		
		public static function showShadow(target:Object):void 
		{
			TweenMax.to(target, 0.25, {dropShadowFilter:{color:0x33ff00, alpha:1, blurX:10, blurY:10}});
		}
		
		public static function showGlow(target:Object):void
		{
			TweenMax.to(target, 0.5, {glowFilter:{color:0xffff00, alpha:1, blurX:30, blurY:30, strength:1, quality:1}});
		}
		
		public static function hideGlow(target:Object):void
		{
			TweenMax.to(target, 0.5, {glowFilter:{color:0xffff00, alpha:0, blurX:30, blurY:30, strength:1, quality:1}});
		}
	}
}
