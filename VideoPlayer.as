package com.editor.view.videoplayer
{
	import com.editor.controller.common.KeyboardMap;
	import com.editor.controller.utils.Utils;
	import com.editor.model.EditorModel;
	import com.editor.view.tip.InsertTipView;
	import com.editor.view.tip.NetworkTipView;
	import com.editor.view.tip.TimeTipView;
	import com.editor.view.videoplayer.network.NetworkCheckView;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import fl.data.DataProvider;
	
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.*;
	
	import org.osflash.signals.Signal;

	
	public class VideoPlayer extends Sprite
	{
		private var _list:Array = [];
		private var _video:Video;
		private var _ns:NetStream;
		private var _nc:NetConnection;
		private var _playerWidth:Number;
		private var _playerHeight:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _client:Object;
		private var _result:String; 
		private var _volume:Number = 0.5; 
		private var _duration:Number;
		private var _seektime:Number;
		private var _isseek:Boolean = false;
		private var _isFineSeek:Boolean = false;
		private var _timerCounter:uint = 0;
		private var _isMouseMoved:Boolean = false;
		private var _controlTimer:Timer = new Timer(1000);
		private var _metadata:Object;
		private var _loadedTime:Number;
		private var _model:EditorModel;
		private var _videoName:String;
		private var _videoURL:String;
		private var _videoState:String;
		private var _loadingPer:int;
		private var _lastTimeMark:Number;
		private var _hasRecord:Boolean = false;
		private var _closeSpeedTipInterval:Number;
		private var _closeLock:Boolean = false;
		private var _closeInsertTipInterval:Number;
		
		
		//控制预览功能实现
		private var _dataprovider:DataProvider;
		private var _currentVideoInfo:Object;
		private var _currentVideoBeginTime:uint;
		private var _currentVideoEndTime:uint;
		private var _isCurrentVideoEnd:Boolean = false;
		private var _currentIndex:int = 0;
		private var _isLocked:Boolean = false;
		private var _isPreviewing:Boolean = false;

		//signals
		public var sendBeginTimeSignal:Signal;  
		public var sendEndTimeSignal:Signal;
		public var lockAllSignal:Signal; 
		public var unlockAllSignal:Signal;
		public var showCurrentRowColor:Signal;
		public var hideCurrentRowColor:Signal;
		public var setPreviewStateSignal:Signal;
		
		//view
		private var _controlBar:ControlBar;
		private var _networkCheck:NetworkCheckView;
		private var _networkTip:NetworkTipView;
		private var _closeNetworkCheckInterval:Number;
		private var _closeNetworkTipInterval:Number;
		private var _speedTip:SpeedTipUI;
		private var _loadingView:LoadingView;
		private var _timeTip:TimeTipView;
		private var _insertTip:InsertTipView;

		
		private static const _LOADINGBAR_LENGTH:Number = 500;
		
		public function VideoPlayer(width:Number, height:Number)
		{
			if (stage)
			{
				return;
			}
			this._playerWidth = width;
			this._playerHeight = height;
			init();
		}
	
		private function init():void
		{
			_client = new Object();
			_video = new Video();
			_video.x = 0;
			_video.y = 0;
			_video.width = this._playerWidth;
			_video.height = this._playerHeight;
			
			_controlBar = new ControlBar();
			_controlBar.name = "_controlBar";
			_controlBar.x = _video.x;
			_controlBar.y = _video.y + _video.height - 40;
			this.addChild(_video); 
			this.addChild(_controlBar);			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onVideoMouseMove);
			this._controlBar.addEventListener(MouseEvent.MOUSE_MOVE, onControlBarMouseMove);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_controlBar.loadingBar.addEventListener(MouseEvent.MOUSE_MOVE, onLoadingMouseMove);
			_controlBar.loadingBarBG.addEventListener(MouseEvent.MOUSE_MOVE, onLoadingMouseMove);
			_controlBar.loadingBar.addEventListener(MouseEvent.MOUSE_OUT, onLoadingMouseOut);
			_controlBar.loadingBarBG.addEventListener(MouseEvent.MOUSE_OUT, onLoadingMouseOut);
			
			sendBeginTimeSignal = new Signal(Object);
			sendEndTimeSignal = new Signal(Object);
			lockAllSignal = new Signal();
			unlockAllSignal = new Signal();
			showCurrentRowColor = new Signal(Object);
			hideCurrentRowColor = new Signal(Object);
			setPreviewStateSignal = new Signal();
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			trace ("keycode:" + event.keyCode);
		}
		
		/**
		 * 
		 * 影片编辑列表数据起始时间、终止时间获取
		 * 
		 */ 
		public function getBeginTime():void
		{
			if (_ns){
				var o:Object = new Object();
				o.影片名称 = videoName; 
				o.起始时间 = (_ns.time).toFixed(3);
				/*if (o.起始时间 < model.endTimeRecord)
				{
					showInsertTip();
					return;
				}*/
				sendBeginTimeSignal.dispatch(o);
				trace ("影片名称:" + o.影片名称);
				trace ("起始时间:" + o.起始时间);
			}
		}
		
		public function getEndTime():void
		{
			if (_ns){
				var o:Object = new Object();
				o.影片名称 = videoName;
				o.终止时间 = (_ns.time).toFixed(3);
				sendEndTimeSignal.dispatch(o);
				trace ("终止时间:" + o.终止时间);  
			}
		}
		
		public function showInsertBeginTimeTip():void
		{
			if (_insertTip == null)
			{
				_insertTip = new InsertTipView();
				_insertTip.x = _video.x + (_LOADINGBAR_LENGTH - _insertTip.width) * 0.5;
				_insertTip.y = _video.y + (_video.height - _insertTip.height) * 0.5;
				_insertTip.gotoAndStop(1);
				this.addChild(_insertTip);
				_closeInsertTipInterval = setInterval(closeInsertTip, 2000); 
			}
		}
		
		public function showInsertEndTimeTip():void
		{
			if (_insertTip == null)
			{
				_insertTip = new InsertTipView();
				_insertTip.x = _video.x + (_LOADINGBAR_LENGTH - _insertTip.width) * 0.5;
				_insertTip.y = _video.y + (_video.height - _insertTip.height) * 0.5;
				_insertTip.gotoAndStop(2);
				this.addChild(_insertTip);
				_closeInsertTipInterval = setInterval(closeInsertTip, 2000); 
			}
		}
		
		private function closeInsertTip():void
		{
			clearInterval(_closeInsertTipInterval);
			if (_insertTip)
			{
				if (this.contains(_insertTip))
				{
					this.removeChild(_insertTip);
					_insertTip = null;
				}
			}
		}
		
		/**
		 * 
		 * 添加播放进度条时间提示框相关事件
		 * 
		 */		
		private function onLoadingMouseMove(event:MouseEvent):void
		{
			if (_ns != null){
				var mx:Number = Math.round(mouseX);
				var my:Number = Math.round(mouseY);
				var totalTime:Number = duration;
				var time:String = Utils.secondToTimeFomat(mx * (duration / _LOADINGBAR_LENGTH));
				if (_timeTip == null){
					_timeTip = new TimeTipView();
					this.addChild(_timeTip);
				}
				if (mx < _timeTip.width * 0.5){
					_timeTip.x = 0;
				}else if (mx > _LOADINGBAR_LENGTH - (_timeTip.width * 0.5)){
					_timeTip.x = _LOADINGBAR_LENGTH - _timeTip.width;
				}else{
					_timeTip.x = mx - (_timeTip.width * 0.5);
				}
				_timeTip.y = _controlBar.y - _timeTip.height;
				_timeTip.updateTime(time);
			}
		}
		
		private function onLoadingMouseOut(event:MouseEvent):void
		{
			if (_timeTip != null){
				if (this.contains(_timeTip)){
					this.removeChild(_timeTip);
					_timeTip = null;
				}
			}
		}
		
		//控制播放头位置及进度条状态改变、影片预览
		private function onEnterFrame(event:Event):void
		{
			if (metadata == null) return;
			if (this._isPreviewing)
			{
				updateControlBar();
				previewVideoPlayHandler();
			}
			else
			{
				normalVideoPlayHandler();
			}
		}
		
		/**
		 * 
		 * 设置控制条为初始化状态
		 * 
		 */		
		protected function updateControlBar():void
		{
			this._controlBar.updateLoadingBar(0);
			this._controlBar.updatePlayHeadPosition(0);
			this._controlBar.updateTime(0, 0);
			this._controlBar.visible = false;	
		}
		
		/**
		 *
		 * 预览播放功能实现 
		 * 
		 */		
		private function previewVideoPlayHandler():void
		{
			if (!this._currentVideoInfo){
				if (!_isLocked){
					if (dataprovider){
						if (dataprovider.length >= 1){
							this._isLocked = true;
							lockAllSignal.dispatch();
							this._currentVideoInfo = dataprovider.getItemAt(this._currentIndex);
						}else{ return;}
					}else{ return;}
				}
			}
			
			if (this._isCurrentVideoEnd)
			{
				if (this._currentIndex < dataprovider.length - 1)
				{
					hideCurrentRowColor.dispatch(this._currentVideoInfo);//当前段播放完成移除选中效果

					this._currentIndex = this._currentIndex + 1;
					this._currentVideoInfo = dataprovider.getItemAt(this._currentIndex); 
					this._isCurrentVideoEnd = false;
					this._currentVideoBeginTime = 0;
					this._currentVideoEndTime = 0;
					trace ("当前段播放完成，开始播放下一段");
				}
				else
				{
					hideCurrentRowColor.dispatch(this._currentVideoInfo);
					setPreviewStateSignal.dispatch();

					this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					this._currentVideoInfo = null;
					this._currentIndex = 0;
					this._isCurrentVideoEnd = false;
					this._currentVideoBeginTime = 0;
					this._currentVideoEndTime = 0;
					this._controlBar.visible = true; 
					
					clear();
					destroyNetStream();
			
					if (this._isLocked)
					{
						this._isLocked = false;
						this._isPreviewing = false;
						unlockAllSignal.dispatch(); 
					}
					trace ("编辑列表中所有影片片段播放完成");
				}
			}
			else
			{
				playCurrentVideo(this._currentVideoInfo);
			}
		}		
		
		/**
		 * 
		 * @param o : 当前正在播放视频片段信息
		 * 
		 */		
		private function playCurrentVideo(o:Object):void
		{
			if (!_currentVideoBeginTime && !_currentVideoEndTime) 
			{
				this._currentVideoBeginTime = o.起始时间;
				this._currentVideoEndTime = o.终止时间;
				videoURL = this.getVideoURLByName(String(o.影片名称));
				showCurrentRowColor.dispatch(o);
			}
			
			if (_ns)
			{
				if (Math.round(_ns.time) == this._currentVideoEndTime)
				{
					this._isCurrentVideoEnd = true;
				}
				trace (_ns.time);
			}
		}
		
		/**
		 * 
		 * @param name ：影片名称
		 * @return 返回影片地址
		 * 
		 */		
		private function getVideoURLByName(name:String):String
		{
			try
			{
				var _url:String = "";
				var _len:int = urls.length;
				var i:int;
				for (i=0; i<_len; i++)
				{
					if (name == urls[i].name)
					{
						_url = urls[i].url;
					}
				}
			}
			catch (e:Error)
			{
				trace ("getVideoURLByName Error:" + e.message);
			}
			
			return _url;
		}
		
		
		/**
		 *
		 * 提前停止预览功能 
		 * 
		 */		
		public function stopPreview():void
		{
			if (this.hasEventListener(Event.ENTER_FRAME))
			{
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
			hideCurrentRowColor.dispatch(this._currentVideoInfo);
			unlockAllSignal.dispatch(); 			
			
			this._isPreviewing = false;
			this._isCurrentVideoEnd = false;
			this._isLocked = false;
			this._currentVideoBeginTime = 0;
			this._currentVideoEndTime = 0;
			this._currentIndex = 0;
			this._currentVideoInfo = null;
			
			this.clear(); 
			this.destroyNetStream();
			this._controlBar.visible = true;
		}
		
		/**
		 *
		 * 正常状态下影片播放控制条状态控制
		 * 
		 */		
		private function normalVideoPlayHandler():void
		{			
			if (_ns)
			{
				/*if (_videoState != VideoState.VIDEO_STATE_STOPED)
				{
					if (_ns.bufferLength <=1)
					{
						showLoading(0);
					}else{
						hideLoading();
					}
				}*/
				
				
				
				//if (this._isseek)
				//{
					//_controlBar.updateTime(duration, _seektime);
					//if (_seektime < _ns.time)
					//{
					//	this._isseek = false;
					//}
					
					
					//this._loadedTime = (_ns.bytesLoaded / _ns.bytesTotal) * duration;
					//if (_loadedTime - 5 > _seektime)
					//{
					//	this._isseek = false;
						//hideLoading();
					//}else{
						//showLoading(Math.round((_loadedTime - 5)/_seektime * 100));
					//}
					
					
					
					
					
					
					/*
					this._loadedTime = (_ns.bytesLoaded / _ns.bytesTotal) * duration;
					if (_loadedTime > _seektime)
					{
						this._isseek = false;
					}
					else
					{
						_loadingPer =  Math.round((_loadedTime / (_seektime + 7)) * 100);   
					}
					showLoading(_loadingPer);
					if (_loadingPer >= 100) 
					{
						this._isseek = false;
					}*/
			//	}
			
			
			
			
				/*else 
				{
					_loadingPer = Math.round((this._ns.bufferLength / this._ns.bufferTime) * 100);
				}
				
				if((_ns.time==0 || _ns.time == _lastTimeMark) && _loadingPer < 100 && (this._videoState == VideoState.VIDEO_STATE_PLAYING))
				{
					showLoading(_loadingPer);
				}
				else
				{
					hideLoading();  
				}
				_lastTimeMark = _ns.time; */
				
				
				if (this._isFineSeek)
				{
					_controlBar.updateLoadingBar(_seektime / duration); 
					_controlBar.updateTime(duration, _seektime);
					_controlBar.updatePlayHeadPosition(_seektime / duration); 
					pause();
					this._isFineSeek = false; 
				}
				else
				{
					_controlBar.updateLoadingBar(_ns.time / duration);
					_controlBar.updateTime(duration, _ns.time);
					_controlBar.updatePlayHeadPosition(_ns.time / duration); 
				}
				
				//trace (_ns.time)
				
				//手动暂停，隐藏缓冲提示
				
				/*if (this._videoState == VideoState.VIDEO_STATE_MANUAL_PAUSE)
				{
					if (_loadingView)
					{
						hideLoading();
					}
				}*/
			}	
		}
		
		/**
		 * 
		 * @param percent ：缓冲百分比
		 * 显示缓冲提示信息
		 * 
		 */		
		private function showLoading(percent:Number=0):void
		{
			if (_loadingView == null){
				_loadingView = new LoadingView();
				_loadingView.x = (_LOADINGBAR_LENGTH - 209.5) * 0.5; // 其中209.5为_loadingView的显示长度，实际长度大于该值
				_loadingView.y = (this.height - 76.05) * 0.5;// 76.05为 loadingView中动态加载的swf文件的高度
				this.addChild(_loadingView);  
			}
			
			if (_loadingView)
			{
				this._loadingView.visible = true;
				_loadingView.updateLoadingPercentage(percent + "%"); 
			}
		}
		
		private function hideLoading():void
		{
			if (_loadingView != null){
				if (this.contains(_loadingView) && this._loadingView.visible){
					this._loadingView.visible = false;
					this._loadingView.updateLoadingPercentage("0%"); 
				}
			}
		}
		
		/**
		 * 
		 * 控制播放控制条显示隐藏状态,当前对象不是_controlBar时隐藏_controlBar
		 * 
		 */		
		private function onVideoMouseMove(event:MouseEvent):void
		{
			if (validate(event))  
			{
				killFadeOutTween(); 
				_controlBar.alpha = 1;
				_isMouseMoved = true;
				_timerCounter = 0;
				_controlTimer.reset();
				_controlTimer.start();
				_controlTimer.addEventListener(TimerEvent.TIMER, onControlTimer);
			}
		}
		
		/**
		 * 
		 * 特殊情况处理，控制底部播放控制条显示隐藏
		 * 
		 */		
		private function validate(event:MouseEvent):Boolean
		{
			var name:String = event.target.name;
		    var res:Boolean = (name != "_controlBar") && (name != "leftJumpBtn") && (name != "rightJumpBtn") &&
				(name != "startBtn") && (name != "pauseBtn") && (name != "stopBtn") && (name != "playHeadBtn") && (name != "loadingBarBG") &&
				(name != "loadingBar") && (name != "volumeBtn") && (name != "volumeBar") && (name != "durationTimeTxt") && (name != "realTimeTxt");
			return res;
		}
		
		/**
		 * 
		 * 控制播放控制条显示隐藏状态
		 * 
		 */		
		private function onControlBarMouseMove(event:MouseEvent):void
		{
			killFadeOutTween();
			_controlBar.alpha = 1;
			_isMouseMoved = false;
			_controlTimer.stop();
			_controlTimer.removeEventListener(TimerEvent.TIMER, onControlTimer);
		}
		
		/**
		 * 
		 * 控制播放控制条2秒后隐藏
		 * 
		 */		
		private function onControlTimer(event:TimerEvent):void
		{
			if (this._isMouseMoved){
				_timerCounter++;
				if (_timerCounter == 2){
					addFadeOutTween();
					_timerCounter = 0;
					_controlTimer.stop();
					_controlTimer.removeEventListener(TimerEvent.TIMER, onControlTimer);
				}
			}
		}
		
		/**
		 *
		 * 淡出效果 
		 * 
		 */		
		private function addFadeOutTween():void
		{
			TweenLite.to(_controlBar, 2, {alpha:0});
		}
		
		/**
		 *
		 * 取消淡出效果 
		 * 
		 */		
		private function killFadeOutTween():void
		{
			TweenLite.killTweensOf(_controlBar, {alpha:true});  
		}
		
		/**
		 *
		 * 连接服务器 
		 * 
		 */		
		private function connect():void
		{
			_nc = new NetConnection();
			_nc.client = this;
			_nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError); 
			_nc.connect(this.rtmp);
		}
		
		public function onBWDone ():void{}
		
		/**
		 *
		 * 初始化视频流 
		 * 
		 */		
		private function initNetStream():void
		{
			clear();
			trace("initNetStream");
			_ns = new NetStream(_nc);
			_ns.bufferTime = 5;
			_client.onMetaData = onMetaData;
			_client.onPlayStatus = forNsStatus;
			_ns.client = _client; 
			_ns.inBufferSeek = true;
			_ns.soundTransform = new SoundTransform(volume);
			_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_ns.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_video.attachNetStream(_ns);
								
			if (this._isPreviewing)
			{
				_ns.play(videoURL);
				_ns.seek(this._currentVideoBeginTime); 
			}
			else
			{
				checkRecord();
				if (!_hasRecord)
				{
					_ns.play(videoURL); 
				}
			}
		}
		
		
		/**
		 *
		 * 从上次记录的最终播放时间开始播放 
		 * 
		 */		
		private function checkRecord():void
		{
			if (model)
			{
				if (model.endTimeRecord)
				{
					_ns.play(videoURL);
					_ns.seek(model.endTimeRecord);
					this._hasRecord = true;
				}else{
					this._hasRecord = false; 
				}
			}
		}
		
	
		public function get videoURL():String
		{
			return _videoURL;
		}
		
		public function set videoURL(value:String):void
		{
			_isPreviewing == true ? _videoURL=value : _videoURL=getVideoURLById(value);
			if (_ns){
				clear();
			}
			if (!this.hasEventListener(Event.ENTER_FRAME)){
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			connect(); 
		}
		
		/**
		 * 
		 * @param id ：影片名称
		 * @return 返回影片路径
		 * 
		 */		
		private function getVideoURLById(id:String):String
		{
			if (urls==null || urls.length == 0)
			{
				trace ("getVideoURLById Error:无法解析影片地址");
				return "";
			}
			
			var url:String = "";
			var _len:int = urls.length;
			for (var i:int=0; i<_len; i++)
			{
				if (id == urls[i].id)
				{
					url = urls[i].url;
					videoName = urls[i].name;
				}
			}
			return url;
		}
		
		/**
		 * 
		 * @param event 
		 * 
		 */		
		private function onNetStatus(event:NetStatusEvent):void
		{
			//trace(event.info["code"]);
			switch(event.info["code"])
			{
				case "NetStream.Play.Start":
					trace("NetStream.Play.Start");
					this._videoState = VideoState.VIDEO_STATE_PLAYING;
					break;
				
				case "NetStream.Play.Stop":
					trace('NetStream.Play.Stop');		
					this._videoState = VideoState.VIDEO_STATE_STOPED;
					break;
				
				case "NetConnection.Connect.Success":
					initNetStream();
					break;
				
				case "NetConnection.Connect.Rejected":
					trace("NetConnection.Connect.Rejected");
					break;
				
				case "NetConnection.Connect.Closed":
					trace(event.info["code"]);
					break;
				
				case "NetConnection.Connect.NetworkChange":
					trace("当前网络状态发生改变"); 
					//networkCheck();
					break;
				
				case "NetStream.Buffer.Empty":
					trace("NetStream.Buffer.Empty");
					break;
				
				case "NetStream.Buffer.Flush":
					trace("NetStream.Buffer.Flush");
					break;
				
				case "NetStream.Buffer.Full":
					trace("NetStream.Buffer.Full");
					break;
				
				case "NetStream.Seek.InvalidTime":
					trace("无法跳转到指定时间点播放");
					if (event.info.details != 0)
					{
						this._ns.seek(event.info.details);
					}
					break;
				
				case "NetConnection.Connect.Failed":
					trace(event.info["code"]);
					break;
				
				case "NetStream.SeekStart.Notify":
					trace("搜索中...");
					break;
				
				case "NetStream.Seek.Notify":
					trace("搜索完成"); 
					break;
			}
		}
		
		/**
		 *
		 * 网络状态监测 
		 * 
		 */		
		private function networkCheck():void
		{
			if (_networkCheck == null)
			{
				_networkCheck = new NetworkCheckView();
				this.addChild(_networkCheck);
				_closeNetworkCheckInterval = setInterval(closeNetworkCheck, 3000);
			}
		}
		
		private function closeNetworkCheck():void
		{
			if (_networkCheck)
			{
				if (this.contains(_networkCheck))
				{
					this.removeChild(_networkCheck);
					_networkCheck = null; 
				}
			}
			clearInterval(_closeNetworkCheckInterval)
		}
		
		public function showNetworkTip(result:Boolean):void
		{
			/*if (_networkTip)
			{
				if (this.contains(_networkTip))
				{
					this.removeChild(_networkTip);
					_networkTip = null;
				}
			}*/
	
			if (_networkTip == null)
			{
				_networkTip = new NetworkTipView();
				_networkTip.x = _video.x + (_LOADINGBAR_LENGTH - _networkTip.width) * 0.5;
				_networkTip.y = _video.y + (_video.height - _networkTip.height) * 0.5;
				_networkTip.updateNetworkStateTip(result);
				this.addChild(_networkTip);	
				_closeNetworkTipInterval = setInterval(closeNetworkTip, 3000);
			}
		}
		
		private function closeNetworkTip():void
		{
			if (_networkTip)
			{
				if (this.contains(_networkTip))
				{
					this.removeChild(_networkTip);
					_networkTip = null;
				}
			}
			clearInterval(_closeNetworkTipInterval);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("IOError:" + event);
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("SecurityError:" + event);
		}
		
		private function onAsyncError(event:AsyncErrorEvent):void
		{
			trace("AsyncError:" + event);
		}
		
		private function forNsStatus(info:Object):void
		{
			if (info.code == "NetStream.Play.Complete"){
				trace(info.code);
				if (!this._isPreviewing)
				{
					this.stop();
				}
			}
		}
		
		public function onMetaData(metadata:Object):void
		{
			this._metadata = metadata;
			duration = metadata.duration;
			trace("影片长度为：" + duration);
		}
	
		/**
		 * 
		 * @param position ：跳转位置百分比
		 * 按比例跳转
		 * 
		 */		
		public function seek(position:Number):void
		{
			try
			{
				if (_ns)
				{
					this._isseek = true;
					this._seektime = position * duration;
					_ns.seek(_seektime);
				}
			}
			catch(e:Error)
			{
				trace("seek:" + e.message);
			}
		}
		
		/**
		 * 
		 * @param time ：跳转时间点
		 * 按时间跳转
		 * 
		 */		
		private function seekDirectly(time:Number):void
		{
			try
			{
				if (_ns)
				{
					this._isFineSeek = true;
					this._seektime = time;
					_ns.seek(_seektime);
				}
			}
			catch(e:Error)
			{
				trace("seek:" + e.message); 
			}
		}
	
		/*************************************************************
		 * 工具方法
		 *************************************************************/ 
		private function clear():void
		{
			if (_ns != null){
				_ns.pause();
				_ns = null;
			}
			
			if (_video){
				_video.clear();
				_video.attachNetStream(null);
			}
			
		}
		
		public function play():void
		{
			if (_ns){
				_ns.resume();
				this._videoState = VideoState.VIDEO_STATE_PLAYING;
			}else{
				load();
			}
		}
		
		public function pause():void
		{
			if (_ns){
				_ns.pause();
				this._videoState = VideoState.VIDEO_STATE_MANUAL_PAUSE;
			}
			return; 
		}
		
		public function stop():void
		{
			clear();
			this._videoState = VideoState.VIDEO_STATE_STOPED;
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_controlBar.updateLoadingBar(0);
			_controlBar.updateTime(0, 0);
			_controlBar.updatePlayHeadPosition(0);
			
		}
		
		/**
		 * 
		 * @param direction : 对当前播放的影片进行微调(每次向前或向后调整100ms)
		 * 
		 */		
		public function updateCurrentPlayPosition(direction:String):void
		{
			if (_ns == null)
			{
				return;
			}
			
			if (this._videoState == VideoState.VIDEO_STATE_PLAYING || this._videoState == VideoState.VIDEO_STATE_MANUAL_PAUSE)
			{
				var _curSeekTime:Number = 0;
				if (direction == KeyboardMap.LEFT_ARROW)
				{
					if (_ns.time > 1)
					{
						_curSeekTime = _ns.time - 0.1;
						this.seekDirectly(_curSeekTime);
						trace ("left_curSeekTime:" + _curSeekTime);
					}
				}
				else if (direction == KeyboardMap.RIGHT_ARROW)
				{
					if (_ns.time < duration - 1)
					{
						_curSeekTime = _ns.time + 0.1;
						this.seekDirectly(_curSeekTime);
						trace ("right_curSeekTime:" + _curSeekTime);
					}
				}
				
				showSpeedTipView(direction);
				if (!_closeLock)
				{
					_closeLock = true;
					_closeSpeedTipInterval = setInterval(closeSpeedTip, 500); 
				}
			}
		}
		
		/**
		 *
		 * 移除closeTip 
		 * 
		 */		
		private function closeSpeedTip():void
		{
			clearInterval(_closeSpeedTipInterval);
			this._closeLock = false
			if (_speedTip)
			{
				if (this.contains(_speedTip))
				{
					this.removeChild(_speedTip);
					_speedTip = null;
				}
			}
		}
		
		/**
		 * 
		 * @param direction : 判定按下的为快进还是快退键
		 * 控件说明
		 * _speedTip为一两帧的影片剪辑
		 * frameRate1 ：文本内容：快进100毫秒
		 * frameRate2 : 文本内容：后退100毫秒
		 * goFrontTxt : 第一帧中的文本框名称
		 * goBackTxt  : 第二帧种的文本框名称
		 * 
		 */		
		private function showSpeedTipView(direction:String):void
		{
			if (_speedTip == null)
			{
				_speedTip = new SpeedTipUI();
				_speedTip.x = _controlBar.x + 16;
				_speedTip.y = _controlBar.y - _speedTip.height - 5;
				this.addChild(_speedTip);
				if (direction == KeyboardMap.LEFT_ARROW){
					_speedTip.gotoAndStop(2);
					//_speedTip.goBackTxt.text = "后退80毫秒";  //动态控制文本框中内容
				}else if (direction == KeyboardMap.RIGHT_ARROW){
					_speedTip.gotoAndStop(1);
					//_speedTip.goFrontTxt.text = "前进40毫秒";
				}
			}
		}
		
		/**
		 *
		 * 响应键盘空格按下事件 
		 * 
		 */		
		public function spaceKeyEventHandler():void
		{
			if (_ns)
			{
				if (_videoState == VideoState.VIDEO_STATE_PLAYING)
				{
					pause();
					trace ("spaceKey : " + "pause");
				}
				else if (_videoState == VideoState.VIDEO_STATE_MANUAL_PAUSE)
				{
					play(); 
					trace ("spaceKey : " + "play");
				}
			}
		}
		
		/**********************************************************
		 * 变量重构
		 **********************************************************/ 
		public function get result():String
		{
			return _result; 
		}
		
		public function set result(value:String):void
		{
			this._result = value;
			load();
		}
		
		private function load():void
		{
			if (_ns){
				clear();
				destroyNetStream();
			}
			
			if (!this.hasEventListener(Event.ENTER_FRAME))
			{
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);  
			}
			connect();
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			this._volume = value;
			if (_ns){
				_ns.soundTransform = new SoundTransform(_volume);
			}
		}
		
		private function get duration():Number
		{
			return _duration;
		}
		
		private function set duration(value:Number):void
		{
			this._duration = value;
		}
		
		public function get metadata():Object
		{
			return _metadata;
		}
		
		public function set metadata(value:Object):void
		{
			this._metadata = value;
		}
		
		public function get model():EditorModel
		{
			return _model;
		}
		
		public function set model(value:EditorModel):void
		{
			this._model = value;
		}
		
		public function get videoName():String
		{
			return _videoName; 
		}
		
		public function set videoName(value:String):void
		{
			this._videoName = value;
		}
		
		public function get dataprovider():DataProvider
		{
			return _dataprovider;
		}
		
		public function set dataprovider(value:DataProvider):void
		{
			_dataprovider = value;
			this._isPreviewing = true;
			
			if (_ns)
			{
				clear(); 
				destroyNetStream();
			}
			
			if (!this.hasEventListener(Event.ENTER_FRAME))
			{
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
	 
		}
		
		private var _urls:Array = new Array();//存放所有影片URL
		
		public function get urls():Array
		{
			return _urls;
		}
		
		public function set urls(value:Array):void
		{
			_urls = value;
		}

		private var _rtmp:String = "";
		public function get rtmp():String
		{
			return _rtmp;
		}
		
		public function set rtmp(value:String):void
		{
			this._rtmp = value;
		}
			
		
		/*************************************************************
		 * 性能优化、内存管理
		 *************************************************************/ 
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_list.push([type,listener,useCapture])
			super.addEventListener(type,listener,useCapture,priority,useWeakReference)
		}
		
		public function destroyNetStream():void
		{
			try
			{
				if (this._ns != null)
				{
					this._ns.pause();
					this._ns.close();
					this._ns.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
					this._ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,onAsyncError);			
					this._ns.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
					this._ns.soundTransform = null;
					this._ns = null;
				}
					
				if (this._nc != null)
				{
					this._nc.close();
					_nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
					_nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
					_nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
					this._nc = null;
				}
			}
			catch(e:Error)  
			{
				trace(e);
				trace("something wrong with destroy netstream");
			}
		}
		
		private function destroy(e:Event):void
		{
			if(e.currentTarget != e.target)return;
			destroyNetStream();
			
			//删除子对象
			trace("删除前有子对象",numChildren)
			while(numChildren > 0)
			{
				removeChildAt(0);
			}
			trace("删除后有子对象",numChildren);
			
			//删除动态属性
			for(var k:String in this){
				trace("删除属性",k)
				delete this[k]
			}
			
			//删除侦听
			trace("删除前注册事件数:" + _list.length)
			for(var i:uint=0;i<_list.length;i++){
				trace("删除Listener",_list[i][0])
				removeEventListener(_list[i][0],_list[i][1],_list[i][2])
			}
			_list = null;
		}
	}
}
