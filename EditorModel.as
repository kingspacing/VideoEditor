package com.editor.model
{
	import fl.data.DataProvider;

	public class EditorModel
	{
		
		/**
		 * 
		 * _beginTime ：存储所选起始时间
		 * _endTime ：存储所选终止时间
		 * _currentSelectedItems ：存储当前选中各项数据
		 * _dataprovider ：编辑列表中所有数据
		 * _isInsert ：是否允许插入数据
		 * _isCanSeek ：是否允许跳转播放
		 * _timeRecord ：记录各路视频最后的播放位置
		 * 
		 */		
		private var _beginTime:Object; 
		private var _endTime:Object; 
		private var _currentSelectedItems:DataProvider;
		private var _dataprovider:DataProvider;
		private var _isInsert:Boolean = false;
		private var _isCanSeek:Boolean = false;
		private var _timeRecord:Array = [];
		private var _endTimeRecord:Number = 0;
		
		/**
		 * _filmStartPath ：片头图片相对路径
		 * _filmStartAdd ：是否添加片头
		 * _filmStartDuration ：片头时常
		 * _transEffect ：转场特效ID
		 *
		 */		
		private var _filmStartAdd:String = "NO";
		private var _filmEndAdd:String = "NO";
		private var _filmStartPath:String = "";
		private var _filmEndPath:String = "";
		private var _filmStartDuration:uint = 3;
		private var _filmEndDuration:uint = 3;//没有设置片头片尾播放时长功能统一设置为3秒
		private var _transEffect:uint;//转场特效对应的ID 
		
		public function EditorModel()
		{
			
		}
		
		public function get transEffect():uint
		{
			return _transEffect;
		}

		public function set transEffect(value:uint):void
		{
			_transEffect = value;
		}

		public function get filmEndDuration():uint
		{
			return _filmEndDuration;
		}

		public function set filmEndDuration(value:uint):void
		{
			_filmEndDuration = value;
		}

		public function get filmStartDuration():uint
		{
			return _filmStartDuration;
		}

		public function set filmStartDuration(value:uint):void
		{
			_filmStartDuration = value;
		}

		public function get filmEndPath():String
		{
			return _filmEndPath;
		}

		public function set filmEndPath(value:String):void
		{
			_filmEndPath = value;
		}

		public function get filmStartPath():String
		{
			return _filmStartPath;
		}

		public function set filmStartPath(value:String):void
		{
			_filmStartPath = value;
		}

		public function get filmEndAdd():String
		{
			return _filmEndAdd;
		}

		public function set filmEndAdd(value:String):void
		{
			_filmEndAdd = value;
		}

		public function get filmStartAdd():String
		{
			return _filmStartAdd;
		}

		public function set filmStartAdd(value:String):void
		{
			_filmStartAdd = value;
		}

		public function get beginTime():Object
		{
			return _beginTime; 
		}
		
		public function set beginTime(value:Object):void
		{
			this._beginTime = value; 
		}
		
		public function get endTime():Object
		{
			return _endTime;
		}
		
		public function set endTime(value:Object):void
		{
			this._endTime = value; 
		}
		
		public function get currentSelectedItems():DataProvider
		{
			return _currentSelectedItems;
		}
		
		public function set currentSelectedItems(value:DataProvider):void
		{
			this._currentSelectedItems = value;
		}
		
		public function get dataprovider():DataProvider
		{
			return _dataprovider;
		}
		
		public function set dataprovider(value:DataProvider):void
		{
			this._dataprovider = value;
		}
		
		public function get isInsert():Boolean
		{
			return _isInsert;
		}
		
		public function set isInsert(value:Boolean):void
		{
			this._isInsert = value;
		}
		
		public function get timeRecord():Array
		{
			return this._timeRecord;
		}
		
		public function set timeRecord(value:Array):void
		{
			this._timeRecord = value;
		}
		
		public function get endTimeRecord():Number
		{
			return _endTimeRecord;
		}
		
		public function set endTimeRecord(value:Number):void
		{
			this._endTimeRecord = value;
		}
		
		public function get isCanSeek():Boolean
		{
			return this._isCanSeek;
		}
		
		public function set isCanSeek(value:Boolean):void
		{
			this._isCanSeek = value;
		}
		
		public function destroy():void
		{
			this.beginTime = null;
			this.endTime = null;
			this.currentSelectedItems = null;
			this.dataprovider = null;
			this.isInsert = false;
			//this.isCanSeek = false;
			this.timeRecord = [];
			this.endTimeRecord = 0;
			this.filmStartAdd = "NO";
			this.filmEndAdd = "NO";
			this.filmStartPath = "";
			this.filmEndPath = "";
			this.filmStartDuration = 3;
			this.filmEndDuration = 3;
			this.transEffect = 1;
		}
	}
}
