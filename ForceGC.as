package com.editor.controller.utils
{
	import flash.net.*;
	import flash.system.System;
	
	public class ForceGC extends Object
	{
		public function ForceGC()
		{
			
		}
		
		public static function gc():void
		{
			try
			{
				new LocalConnection().connect("foolish");
				new LocalConnection().connect("foolish");
			}
			catch (e:Error)
			{
			}
		}
		
		public function get used():Number
		{
			return System.totalMemory;
		}
	}
}
