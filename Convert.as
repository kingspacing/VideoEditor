package com.editor.controller.common
{
	import fl.data.DataProvider;
	
	import flash.net.FileReference;

	public class Convert
	{
		public static function convert(dp:DataProvider,path:Array,filmInfo:Object,transEffect:uint):XML
		{
			var xml:XML;
			var xmlContent:String = '';
			var bodyContent:String = '';
			var xmlHead:String = "<?xml version='1.0' encoding='utf-8'?>";
			var bodyHead:String = "<message>";
			var bodyTail:String = "</message>";
			
			var filmStartNode:String = "<filmStart add='" + filmInfo.filmStart.add + "' duration='" + filmInfo.filmStart.duration + "'>" + filmInfo.filmStart.path + "</filmStart>";
			var filmEndNode:String =  "<filmEnd add='" + filmInfo.filmEnd.add + "' duration='" + filmInfo.filmEnd.duration + "'>" + filmInfo.filmEnd.path + "</filmEnd>";
			
			var videoPath:String = "";
			var videoPathHead:String = "<Path>";
			var videoPathTail:String = "</Path>";
			var videoPathBody:String = "";
			var videoPathArray:Array = new Array();
			for (var j:int=0; j < path.length; j++)
			{
				var o:Object = path[j];
				videoPathArray[j] = "<VideoPath ID='" + o.id + "' " + "Audio='" + o.audio + "'>" + o.path + "</VideoPath>";
				videoPathBody += videoPathArray[j];
			}	
			videoPath = videoPathBody;
			//videoPath = videoPathHead + videoPathBody + videoPathTail;
			
			var videoList:String = '';
			var videoListHead:String = "<List>";
			var videoListTail:String = "</List>";
			var videoListBody:String = "";
			var videoListArray:Array = new Array();
			for (var i:int = 0; i < dp.length; i++)
			{
				var item:Object = dp.getItemAt(i);
				videoListArray[i] = "<VideoList ID='" + item.影片名称 + "' " + "transEffect='" + transEffect + "' BeginTime='" + item.起始时间 + "' EndTime='" + item.终止时间 + "'></VideoList>";
				videoListBody += videoListArray[i];
			}
			//videoList = videoListHead + videoListBody + videoListTail;
			videoList = videoListBody;
			
			
			
			bodyContent = filmStartNode + filmEndNode + videoPath + videoList;
			xmlContent = xmlHead + bodyHead + bodyContent + bodyTail;
			xml = new XML(xmlContent);
			//trace (xml);
			return xml;
		}
		
		public static function get targetName():String
		{
			var _name:String;
			var _year:String;
			var _month:String;
			var _day:String;
			var _hour:String;
			var _minute:String;
			var _second:String;
			var _date:Date = new Date();
			
			_year = String(_date.fullYear);
			_date.month + 1 > 9 ? _month = String(_date.month + 1) : _month = String("0" + String(_date.month + 1));
			_date.date > 9 ? _day = String(_date.date) : _day = String("0" + String(_date.date));
			_date.hours > 9 ? _hour = String(_date.hours) : _hour = String("0" + String(_date.hours));
			_date.minutes > 9 ? _minute = String(_date.minutes) : _minute = String("0" + String(_date.minutes));
			_date.seconds > 9 ? _second = String(_date.seconds) : _second = String("0" + String(_date.seconds));
			_name = _year + _month + _day + _hour + _minute + _second;
			
			return _name;
		}
	}
}
