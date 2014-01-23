package com.editor.controller.utils
{
	public class TimeUtil
	{
		public function TimeUtil()
		{
			
		}
		
		//转换时间 1.001为 00:00:01:001 这种形式，精确到毫秒
		public static function timeToString(currentTime:Number) : String
		{
			var _hour:String = '';
			var _minute:String = '';
			var _second:String = '';
			var _ms:String = '';
			
			_hour = String(100+Math.floor(currentTime/3600)).substr(1,2);
			_minute = String(100+Math.floor(currentTime/60) % 60).substr(1,2);
			_second = String(100+Math.floor(currentTime%60)).substr(1,2);
			_ms = String(currentTime).substring(String(currentTime).lastIndexOf(".") + 1, String(currentTime).length);
			if(_hour!='00')
			{				
				if (Number(_ms) <= 9) 
				{
					_ms = "00" + _ms;
				}
				else if (Number(_ms) <= 99) 
				{
					_ms = "0" + Number(_ms);
				}
					
				return _hour +":"+_minute+":"+_second + ":" + Number(_ms);
				
			}
			else
			{
				if (Number(_ms) <= 9) 
				{
					_ms = "00" + Number(_ms);
				}
				else if (Number(_ms) <= 99) 
				{
					_ms = "0" + Number(_ms);
				}
				return "00:" + _minute+":"+_second + ":" + _ms;
			}
		}
		
		//转换时间 00:00:01:001为 1.001 这种形式，精确到毫秒
		public static function stringToTime(currentTime:String) : Number
		{
			var _result:Number = 0;
			var _hour:String = '';
			var _minute:String = '';
			var _second:String = '';
			var _ms:String = '';
			
			_hour = currentTime.substr(0, 2);
			_minute = currentTime.substr(3,2);
			_second = currentTime.substr(6,2);
			_ms = currentTime.substr(9,currentTime.length);
			_result = Number((int(_hour) * 3600 + int(_minute) * 60 + int(_second) + int(_ms) * 0.001).toFixed(3));
			return _result
		}
		
		//将以秒为单位的时间转换为 00:00:00 形式， 精确到秒，忽略毫秒数据
		public static function secondToTime(currentTime:Number):String
		{
			var _hour:String = '';
			var _minute:String = '';
			var _second:String = '';
			
			_hour = String(100+Math.floor(currentTime/3600)).substr(1,2);
			_minute = String(100+Math.floor(currentTime/60) % 60).substr(1,2);
			_second = String(100+Math.floor(currentTime%60)).substr(1,2);
			if(_hour!='00')
			{				
				return _hour +":"+_minute+":"+_second;
				
			}
			else
			{
				return "00:" + _minute+":"+_second;
			}
		}
	}
}
