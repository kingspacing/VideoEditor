package com.editor.view
{
	import com.editor.controller.common.Convert;
	import com.editor.controller.common.Effect;
	import com.editor.controller.common.Upload;
	import com.editor.controller.utils.Lock;
	import com.editor.controller.utils.Utils;
	import com.editor.view.editlist.EditListView;
	import com.editor.view.editlist.EditView;
	import com.editor.view.tip.ConvertTipView;
	import com.editor.view.tip.GetVideoURLErrorView;
	import com.editor.view.tip.UploadTipView;
	import com.editor.view.tip.UserManualView;
	import com.editor.view.videoplayer.*;
	
	import fl.controls.ComboBox;
	
	import flash.display.*;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.text.*;
	import flash.utils.*;
	
	import org.osflash.signals.Signal;
	
	public class MainView extends EditUI
	{

		//variables
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _list:Array =  new Array();
		private var _effectButtonContainer:Vector.<MovieClip> = new Vector.<MovieClip>;
		private var _videoButtonContainer:Vector.<MovieClip> = new Vector.<MovieClip>;
		private var _uploadRequest:URLRequest;
		private var _fileReference:FileReference;
		private var _urlLoader:URLLoader;
		private var _closeConvertTipInterval:Number;
		private var _autoLockInterval:Number;
		private var _closeUploadTipInterval:Number;
		private var _closeUploadFlag:Boolean = true;
		private var _userManualTimer:Timer = new Timer(100);
		private var _userManualTimerCounter:int = 0;
		public var _fileFolderName:String = "";
		public var _existVideos:Array = [];
		private var _flashVars:String = "";
		public var _videoURLs:Array = [];
		private var _rtmp:String = "";
		
		//view
		private var _videoPlayer:VideoPlayer;
		private var _editList:EditListView;
		private var _editView:EditView;
		private var _convertTip:ConvertTipView;
		private var _loadXMLErrorTip:GetVideoURLErrorView;
		private var _uploadTip:UploadTipView;
		private var _userManual:UserManualView;
		private var _showUserManualLoading:greenLoading;
		

		//signal
		public var playVideoSignal:Signal = new Signal();
		public var getBeginTimeSignal:Signal = new Signal();
		public var getEndTimeSignal:Signal = new Signal();
		public var sendFilmBeginPathSignal:Signal = new Signal(String);
		public var sendFilmEndPathSignal:Signal = new Signal(String);
		public var sendEffectIDSignal:Signal = new Signal(uint);
		public var previewSignal:Signal = new Signal();
		public var convertSignal:Signal = new Signal();
		public var stopPreviewSignal:Signal = new Signal();
		public var setHeadCheckSelectedStateSignal:Signal = new Signal(String);
		public var setTailCheckSelectedStateSignal:Signal = new Signal(String);
		public var setHeadImageDurationSignal:Signal = new Signal(uint);
		public var setTailImageDurationSignal:Signal = new Signal(uint);
		public var setVideoURLSignal:Signal = new Signal(Array, String);
		
		public function MainView()
		{
			if (stage)
			{
				initApp();
			}
			else 
			{
				this.addEventListener(Event.ADDED_TO_STAGE,initApp);  
			}
		}
		
		protected function initApp(event:Event = null):void
		{
			this._scaleX = Capabilities.screenResolutionX;
			this._scaleY = Capabilities.screenResolutionY;
			this.x = (_scaleX - this.width) * 0.5;
			this.y = 50; 
			
			//添加播放器
			this._videoPlayer = new VideoPlayer(500,375);
			this._videoPlayer.x = this.videoBG.x;
			this._videoPlayer.y = this.videoBG.y; 
			this.addChild(_videoPlayer);
			
			//添加编辑列表
			this._editList = new EditListView();
			this._editList.x = this.editList.x + 3.5;
			this._editList.y = this.editList.y + 47;
			this.addChild(_editList);
			
			//添加编辑列表控制项
			this._editView = new EditView();
			this._editView.x = this.editList.x + 3;
			this._editView.y = this.editList.y + 350;
			this.addChild(_editView);
		
			initSetting();
			addListener();
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			
			/**
			 * 
			 * 获取各路影片信息
			 * 
			 */
			var info:Object = this.loaderInfo.parameters;
			for(var varName:String in info)
			{
				var o:Object = new Object();
				o.id = varName;
				o.name = getVideoName(varName);
				o.url = info[varName];
				o.exist = false;
				if (o.id == "rtmp")
				{
					this._rtmp = info[varName];
					continue;
				}
				if (info[varName] == "") continue;
				this._videoURLs.push(o);
			}
			updatePlayBtnState(this._videoURLs);//更新六路视频播放按钮状态
			this.setVideoURLSignal.dispatch(this._videoURLs, this._rtmp);//将数据传输到播放器
		}
		
		/**
		 *
		 * 初始化界面状态 
		 * 
		 */		
		private function initSetting():void
		{
			this.videoEditFrame.videoHeadSearchBtn.mouseEnabled = false;
			this.videoEditFrame.videoTailSearchBtn.mouseEnabled = false;
			this.videoEditFrame.headDurationComboBox.mouseEnabled = false;
			this.videoEditFrame.headDurationComboBox.mouseChildren = false;
			this.videoEditFrame.tailDurationComboBox.mouseEnabled = false;
			this.videoEditFrame.tailDurationComboBox.mouseChildren = false;
			this.stopPreviewBtn.visible = false; 
			this.previewBtn.visible = true;
			this.uploadTipTxt.visible = false;
			this.uploadTipTxt.selectable = false;
		}
		
		/**
		 * 
		 * 
		 * 控件说明：
		 * @画面设置
		 * videoEditFrame ： 画面设置与转场特效所在的MovieClip；
		 * videoSourceBox：六路视频对应的控件的容器；
		 * 
		 * @六路视频对应的播放按钮
		 * teacherPlayBtn：老师对应的视频播放按钮；
		 * studentPlayBtn ；
		 * VGAPlayBtn ；
		 * teacherPanoramaBtn ；
		 * studentPanoramaBtn ；
		 * blackboardBtn ；
		 * 
		 * @六路视频对应的标题
		 * teacherTitle：老师对应的标题 ；
		 * studentTitle ；
		 * VGATitle ；
		 * teacherPanoramaTitle ；
		 * studentPanoramaTitle ；
		 * blackboardTitle ；
		 * 
		 * headCheckBox：片头选项对应的CheckBox；
		 * tailCheckBox：片尾选项对应的CheckBox；
		 * videoHeadSearchBtn：片头选项对应”浏览按钮“；
		 * videoTailSearchBtn：片尾选项对应的“浏览按钮”；
		 * 
		 * @转场特效
		 * 几种转场特效分别对应的按钮：
		 * leftPushBtn：左推进；
		 * fourAngleBtn：四角飞出；
		 * leftPressBtn：左边挤压；
		 * cleanScreenBtn：扫屏；
		 * fadeBtn：淡入淡出；
		 * noEffectBtn：无效果
		 * 
		 * @几个控制按钮说明：
		 * startRecordBtn：开始录制；
		 * stopRecordBtn：停止录制；
		 * previewBtn：影片预览；
		 * convertBtn：开始转换；
		 * videoBG：中部黑色区域(播放器背景)；
		 * editList：影片编辑列表背景；
		 * 
		 * 
		 */ 
		
		private function addListener():void
		{
			_effectButtonContainer.push(videoEditFrame.leftPushBtn);
			_effectButtonContainer.push(videoEditFrame.fourAngleBtn);
			_effectButtonContainer.push(videoEditFrame.leftPressBtn);
			_effectButtonContainer.push(videoEditFrame.cleanScreenBtn);
			_effectButtonContainer.push(videoEditFrame.fadeBtn);
			_effectButtonContainer.push(videoEditFrame.noEffectBtn);
			addEffectEventListener();
			
			_videoButtonContainer.push(videoEditFrame.videoSourceBox.teacherPlayBtn);
			_videoButtonContainer.push(videoEditFrame.videoSourceBox.studentPlayBtn);
			_videoButtonContainer.push(videoEditFrame.videoSourceBox.VGAPlayBtn);
			_videoButtonContainer.push(videoEditFrame.videoSourceBox.teacherPanoramaBtn);
			_videoButtonContainer.push(videoEditFrame.videoSourceBox.studentPanoramaBtn);
			_videoButtonContainer.push(videoEditFrame.videoSourceBox.blackboardBtn);
			addVideoButtonEventListener();
			
			initialize();
			initTitleState();
			
			this.videoEditFrame.headCheckBox.addEventListener(MouseEvent.CLICK, headCheckBoxClickHandler);
			this.videoEditFrame.tailCheckBox.addEventListener(MouseEvent.CLICK, tailCheckBoxClickHandler);
			
			this.videoEditFrame.videoHeadSearchBtn.addEventListener(MouseEvent.CLICK, videoHeadSearchBtnClickHandler);
			this.videoEditFrame.videoTailSearchBtn.addEventListener(MouseEvent.CLICK, videoTailSearchBtnClickHandler);
			
			this.setRecordBeginBtn.addEventListener(MouseEvent.CLICK, setRecordBeginBtnClickHandler);
			this.setRecordBeginBtn.addEventListener(MouseEvent.MOUSE_OVER, buttonMouseOverHandler);
			this.setRecordBeginBtn.addEventListener(MouseEvent.MOUSE_OUT, buttonMouseOutHandler);
			
			this.setRecordEndBtn.addEventListener(MouseEvent.CLICK, setRecordEndBtnClickHandler);
			this.setRecordEndBtn.addEventListener(MouseEvent.MOUSE_OVER, buttonMouseOverHandler);
			this.setRecordEndBtn.addEventListener(MouseEvent.MOUSE_OUT, buttonMouseOutHandler);
			
			this.previewBtn.addEventListener(MouseEvent.CLICK, previewBtnClickHandler);
			this.previewBtn.addEventListener(MouseEvent.MOUSE_OVER, buttonMouseOverHandler);
			this.previewBtn.addEventListener(MouseEvent.MOUSE_OUT, buttonMouseOutHandler);
			
			this.stopPreviewBtn.addEventListener(MouseEvent.CLICK, stopPreviewBtnClickHandler);
			this.stopPreviewBtn.addEventListener(MouseEvent.MOUSE_OVER, buttonMouseOverHandler);
			this.stopPreviewBtn.addEventListener(MouseEvent.MOUSE_OUT, buttonMouseOutHandler);
				
			this.convertBtn.addEventListener(MouseEvent.CLICK, convertBtnClickHandler);
			this.convertBtn.addEventListener(MouseEvent.MOUSE_OVER, buttonMouseOverHandler);
			this.convertBtn.addEventListener(MouseEvent.MOUSE_OUT, buttonMouseOutHandler);
			
			this.bottomTipBar.addEventListener(MouseEvent.MOUSE_DOWN, onBottomTipBarMouseDown);
			this.bottomTipBar.addEventListener(MouseEvent.MOUSE_UP, onBottomTipBarMouseUp);
		
		}
		
		private function addEffectEventListener():void
		{
			for (var i:int=0;i<6;i++){
				listener(_effectButtonContainer[i]);
			}
		}
		
		private function addVideoButtonEventListener():void
		{
			for (var i:int=0;i<_videoButtonContainer.length;i++){
				_videoButtonContainer[i].addEventListener(MouseEvent.CLICK, videoPlayButtonClickHandler);
			}
		}
		
		private function listener(eventdispatcher:IEventDispatcher):void
		{
			eventdispatcher.addEventListener(MouseEvent.CLICK, effectBtnMouseEventHandler);
			eventdispatcher.addEventListener(MouseEvent.MOUSE_OVER, effectBtnMouseEventHandler);
			eventdispatcher.addEventListener(MouseEvent.MOUSE_OUT, effectBtnMouseEventHandler);
		}
		
		private function initialize():void
		{
			videoPlayButtonInit();
			checkBoxInit();
			transEffectInit();
			comboBoxInit();
		}
		
		private function checkBoxInit():void
		{
			this.videoEditFrame.headCheckBox.selected = false;
			this.videoEditFrame.tailCheckBox.selected = false;
		}
		
		private function comboBoxInit():void
		{
			(this.videoEditFrame.headDurationComboBox as ComboBox).selectedIndex = 2;
			(this.videoEditFrame.tailDurationComboBox as ComboBox).selectedIndex = 2; 
			this.videoEditFrame.headDurationComboBox.addEventListener(Event.CHANGE, onComboBoxChange);
			this.videoEditFrame.tailDurationComboBox.addEventListener(Event.CHANGE, onComboBoxChange);
		}
		
		private function onComboBoxChange(event:Event):void
		{
			if (event.currentTarget == this.videoEditFrame.headDurationComboBox){
				setHeadImageDurationSignal.dispatch(uint(event.target.selectedItem.data))
			}else{
				setTailImageDurationSignal.dispatch(uint(event.target.selectedItem.data))
			}
		}
		
		private function videoPlayButtonInit():void
		{
			for (var i:int=0; i<_videoButtonContainer.length; i++){
				_videoButtonContainer[i].buttonMode = true;
			}
		}
		
		private function transEffectInit():void
		{
			for (var i:int=0; i < _effectButtonContainer.length; i++){
				_effectButtonContainer[i].gotoAndStop(1);
				_effectButtonContainer[i].buttonMode = true;
			}
			_effectButtonContainer[5].gotoAndStop(3); //默认无特效按钮为选中状态
			sendEffectIDSignal.dispatch(0); 
		}
		
		/**
		 * 
		 * 设置所有转场特效按钮为未选中状态
		 * 
		 */ 
		private function setNoEffect():void
		{
			for (var i:int=0; i < _effectButtonContainer.length; i++){
				_effectButtonContainer[i].gotoAndStop(1);
				_effectButtonContainer[i].buttonMode = true; 
			}
		}
		
		/**
		 * 
		 * 根据获取数据判定各路视频是否有数据，初始化播放按钮
		 * 
		 */ 
		public function updatePlayBtnState(urls:Array):void
		{
			var obj:Object = new Object();
			var _exist:Boolean = false;
			var videos:Array = new Array("teacher","student","VGA","panorama","studentPanorama","blackboard");

			for (var i:int=0; i<videos.length; i++)
			{
				for (var j:int = 0; j < urls.length; j++)
				{
					if (videos[i] == urls[j].id)
					{
						_exist = true;
						_existVideos.push(urls[j]);
						break;
					}
				}
				
				if (_exist)
				{
					_videoButtonContainer[i].gotoAndStop(2);
					_exist = false;
				}
				else 
				{
					_videoButtonContainer[i].gotoAndStop(1);
					_exist = false;
				}
			}
		}
		
		/**
		 *
		 * 网络异常情况下，播放按钮状态初始化 
		 * 
		 */		
		public function updatePlayBtnStateWhenNetworkFailure():void
		{
			var _len:int = _videoButtonContainer.length;
			for (var i:int=0; i < _len; i++)
			{
				_videoButtonContainer[i].gotoAndStop(1);
			}
		}
		
		/**
		 * 六路视频名称为MovieClip共两帧
		 * frameRate1 ：正常状态；
		 * frameRate2 ：该路视频处于播放状态；
		 */ 
		private function initTitleState():void
		{
			this.videoEditFrame.videoSourceBox.teacherTitle.gotoAndStop(1);
			this.videoEditFrame.videoSourceBox.studentTitle.gotoAndStop(1);
			this.videoEditFrame.videoSourceBox.VGATitle.gotoAndStop(1);
			this.videoEditFrame.videoSourceBox.teacherPanoramaTitle.gotoAndStop(1);
			this.videoEditFrame.videoSourceBox.studentPanoramaTitle.gotoAndStop(1);
			this.videoEditFrame.videoSourceBox.blackboardTitle.gotoAndStop(1);
		}
		
		/**
		 * 六路视频名称为MovieClip共两帧
		 * frameRate1 ：正常状态；
		 * frameRate2 ：该路视频处于播放状态；
		 */ 
		private function updateTitleState(name:String):void
		{
			initTitleState();
			switch (name)
			{
				case "teacherPlayBtn":
					this.videoEditFrame.videoSourceBox.teacherTitle.gotoAndStop(2)
					break;
				case "studentPlayBtn":
					this.videoEditFrame.videoSourceBox.studentTitle.gotoAndStop(2);
					break;
				case "VGAPlayBtn":
					this.videoEditFrame.videoSourceBox.VGATitle.gotoAndStop(2);
					break;
				case "teacherPanoramaBtn":
					this.videoEditFrame.videoSourceBox.teacherPanoramaTitle.gotoAndStop(2);
					break;
				case "studentPanoramaBtn":
					this.videoEditFrame.videoSourceBox.studentPanoramaTitle.gotoAndStop(2);
					break;
				case "blackboardBtn":
					this.videoEditFrame.videoSourceBox.blackboardTitle.gotoAndStop(2);
					break;
				default:
					break;

			}
		}
	
		/**
		 * 六路视频播放对应时间处理
		 * 播放按钮为两帧的MovieClip
		 * frameRate1 ：不可点击状态(对应该路无视频数据)；
		 * frameRate2 : 可点击状态，即该路有视频数据。
		 */ 
		private function videoPlayButtonClickHandler(event:MouseEvent):void
		{
			var name:String = event.currentTarget.name as String;
			if (event.currentTarget.currentFrame == 2)
			{
				updateTitleState(name);
				name = mapName(name);
				playVideoSignal.dispatch(name);
				setAutoLock(event.target);
			}
		}
		
		/**
		 * 
		 * @param target : 当前对象
		 * 添加自解锁处理，放置频繁点击播放造成对服务器频繁请求
		 * 
		 */		
		private function setAutoLock(target:Object):void
		{
			Lock.lock(target);
			_autoLockInterval = setInterval(autoLock, 100, target);
		}
		
		private function autoLock(target:Object):void
		{
			Lock.unlock(target);
			clearInterval(_autoLockInterval);
		}
		
		/**
		 * 
		 * @param name
		 * 这种处理方法有一定的风险，一个字母写错可能导致该路视频无法播放 
		 * 
		 */		
		private function mapName(name:String):String
		{
			switch (name)
			{
				case "teacherPlayBtn":
					name = "teacher";
					break;
				case "studentPlayBtn":
					name = "student";
					break;
				case "VGAPlayBtn":
					name = "VGA";
					break;
				case "teacherPanoramaBtn":
					name = "panorama";
					break;
				case "studentPanoramaBtn":
					name = "studentPanorama";
					break;
				case "blackboardBtn":
					name = "blackboard"; 
					break;
				default:
					break;
			}
			return name;
		}
	
		/**
		 * 
		 * 控制片头片尾上传按钮是否可用
		 * 
		 */ 
		private function headCheckBoxClickHandler(event:MouseEvent):void
		{
			if (this.videoEditFrame.headCheckBox.selected)
			{
				this.videoEditFrame.videoHeadSearchBtn.mouseEnabled = true;
				this.videoEditFrame.headDurationComboBox.mouseEnabled = true;
				this.videoEditFrame.headDurationComboBox.mouseChildren = true;
				setHeadCheckSelectedStateSignal.dispatch("YES");
				Utils.showShadow(this.videoEditFrame.videoHeadSearchBtn);
			}
			else
			{
				this.videoEditFrame.videoHeadSearchBtn.mouseEnabled = false;
				this.videoEditFrame.headDurationComboBox.mouseEnabled = false;
				this.videoEditFrame.headDurationComboBox.mouseChildren = false;
				setHeadCheckSelectedStateSignal.dispatch("NO");
				Utils.hideShadow(this.videoEditFrame.videoHeadSearchBtn);
			}
		}
		
		private function tailCheckBoxClickHandler(event:MouseEvent):void
		{
			if (this.videoEditFrame.tailCheckBox.selected)
			{
				this.videoEditFrame.videoTailSearchBtn.mouseEnabled = true;
				this.videoEditFrame.tailDurationComboBox.mouseEnabled = true;
				this.videoEditFrame.tailDurationComboBox.mouseChildren = true;
				setTailCheckSelectedStateSignal.dispatch("YES");
				Utils.showShadow(this.videoEditFrame.videoTailSearchBtn);
			}
			else
			{
				this.videoEditFrame.videoTailSearchBtn.mouseEnabled = false;
				this.videoEditFrame.tailDurationComboBox.mouseEnabled = false;
				this.videoEditFrame.tailDurationComboBox.mouseChildren = false;
				setTailCheckSelectedStateSignal.dispatch("NO");
				Utils.hideShadow(this.videoEditFrame.videoTailSearchBtn);
			}
		}
		
		/**
		 * 片头图片上传处理
		 */ 
		private function videoHeadSearchBtnClickHandler(event:MouseEvent):void
		{
			Utils.hideShadow(event.target);
			_fileReference = new FileReference();			
			_fileReference.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_fileReference.addEventListener(Event.COMPLETE, onFilmBeginUploadComplete);
			_fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_fileReference.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_fileReference.addEventListener(Event.SELECT, onHeadSelect);
			_fileReference.addEventListener(Event.OPEN, onOpen);
			_fileReference.addEventListener(Event.CANCEL, onCancel);
			_fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadComplete);
			var imagesFilter:FileFilter = new FileFilter("Images: (*.jpg)", "*.jpg");
			_fileReference.browse([imagesFilter]);
		}
		
		/**
		 * 片尾图片上传处理
		 */ 
		private function videoTailSearchBtnClickHandler(event:MouseEvent):void
		{
			Utils.hideShadow(event.target);
			_fileReference = new FileReference(); 
			_fileReference.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_fileReference.addEventListener(Event.COMPLETE, onFilmEndUploadComplete);
			_fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_fileReference.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_fileReference.addEventListener(Event.SELECT, onTailSelect);
			_fileReference.addEventListener(Event.OPEN, onOpen);
			_fileReference.addEventListener(Event.CANCEL, onCancel);
			_fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadComplete);
			var imagesFilter:FileFilter = new FileFilter("Images: (*.jpg)", "*.jpg");
			_fileReference.browse([imagesFilter]); 
		}
		
		/**
		 * 
		 * @param event : 服务器返回数据信息
		 * 图片上传完成，服务器返回上传结果；
		 * 
		 */		
		private function onUploadComplete(event:DataEvent):void
		{
			var _result:String = event.data; 
			if (_result == "success")
				showImageUploadTip(true);
			else
				showImageUploadTip(false);
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			//trace("图片上传百分比：" + (event.bytesLoaded / event.bytesTotal) * 100 + "%");
		}
		
		private function onFilmBeginUploadComplete(event:Event):void
		{
			var path:String = _fileFolderName + "_upend" + "/piantou.jpg";
			sendFilmBeginPathSignal.dispatch(path);
			trace("片头图片上传完成");
		}
		
		private function onFilmEndUploadComplete(event:Event):void
		{
			var path:String = _fileFolderName + "_upend" + "/pianwei.jpg"; 
			sendFilmEndPathSignal.dispatch(path);
			trace("片尾图片上传完成");  
		}
		
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			trace("onHttpStatus" + event);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("file uplaod IOError" + event);
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("file upload securityError:" + event);
		}
		
		/**
		 * 
		 * 片头、片尾、生成的XML文件放在相同的文件夹下
		 * 转换开始后文件夹名重新赋值为空字符串
		 * 
		 */		
		private function onHeadSelect(event:Event):void
		{
			_uploadRequest=new URLRequest();
			_uploadRequest.url= Upload.IMAGE_UPLOAD_URL;
			_uploadRequest.method=URLRequestMethod.POST;
			
			if (!_fileFolderName)
			{
				this._fileFolderName = Convert.targetName;
			}
			
			var variables:URLVariables = new URLVariables();
			variables["url"] = String(_fileFolderName + "/piantou.jpg");
			_uploadRequest.data = variables;          
			
			var loader:URLLoader=new URLLoader();   
			loader.load(_uploadRequest);
			loader.addEventListener(Event.COMPLETE,onComHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
			loader.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			
			var uploadDataFiledName:String = "Filedata";
			_fileReference.upload(_uploadRequest,uploadDataFiledName);   
				 
		}
		
		private function onTailSelect(event:Event):void
		{
			_uploadRequest=new URLRequest();
			_uploadRequest.url=Upload.IMAGE_UPLOAD_URL;
			_uploadRequest.method=URLRequestMethod.POST;
			
			if (!_fileFolderName)
			{
				this._fileFolderName = Convert.targetName;
			}
			var variables:URLVariables = new URLVariables();
			variables["url"] = String(_fileFolderName + "/pianwei.jpg"); 
			_uploadRequest.data = variables; 
		
			var loader:URLLoader=new URLLoader();   
			loader.load(_uploadRequest);
			loader.addEventListener(Event.COMPLETE,onComHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
			loader.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			
			var uploadDataFiledName:String = "Filedata";
			_fileReference.upload(_uploadRequest,uploadDataFiledName);  
		}
		
		private function onComHandler(event:Event):void
		{
			
		}
		private function ioerrorHandler(event:IOErrorEvent):void{
			//trace (event);
		}
		private function progressHandler(event:ProgressEvent):void{
			//trace (event);
		}
		private function onOpen(event:Event):void{
			//trace (event);
		}
		
		private function onCancel(event:Event):void{
			//trace("file upload cancel:" + event);
		}
		
		/**
		 * <1>转场特效事件处理：
		 * 六种特效按钮的三种状态 
		 * 第一帧：普通状态；
		 * 第二帧：鼠标滑过状态；
		 * 第三帧：鼠标点击状态。
		 * 
		 * <2>转场特效对应ID：
		 * 1：无效果
		 * 2：从左边推进
		 * 32：四角飞出
		 * 33：扫屏
		 * 23：从左边挤压
		 * 35：淡入淡出
		 * 
		 * <3>特效对应控件名称：
		 * leftPushBtn：左推进；
		 * fourAngleBtn：四角飞出；
		 * leftPressBtn：左边挤压；
		 * cleanScreenBtn：扫屏；
		 * fadeBtn：淡入淡出；
		 * noEffectBtn：无效果
		 * 
		 * 六种特效按钮均为三帧的MovieClip
		 * frameRate1 ：正常状态；
		 * frameRate2 ：鼠标滑过状态；
		 * frameRate3 : 选中状态；
		 */ 
		private function effectBtnMouseEventHandler(event:MouseEvent):void
		{
			switch (event.type){
				case MouseEvent.MOUSE_OVER:
					if (event.currentTarget.currentFrame != 3){
						event.currentTarget.gotoAndStop(2);
						Utils.showShadow(event.target);
					}
					break;
				case MouseEvent.MOUSE_OUT:
					if (event.currentTarget.currentFrame != 3){
						event.currentTarget.gotoAndStop(1)
						Utils.hideShadow(event.target);
					}
					break;
				case MouseEvent.CLICK:
					setNoEffect();
					event.currentTarget.gotoAndStop(3);
					Utils.hideShadow(event.target);
					recordEffectID(event.currentTarget.name);
					break;
				default:
					break;
			}
			
		}
		
		/**
		 * 
		 * 获取并记录当前选择的转场特效对应的ID
		 * 
		 */ 
		private function recordEffectID(name:String):void
		{
			var id:uint = 1;//默认无效果
			switch (name){
				case "noEffectBtn":
					id = Effect.NO_EFFECT;
					break;
				case "leftPushBtn":
					id = Effect.LEFT_PUSH;
					break;
				case "fourAngleBtn":
					id = Effect.FOUR_ANGLE;
					break;
				case "cleanScreenBtn":
					id = Effect.CLEAN_SCREEN;
					break;
				case "leftPressBtn":
					id = Effect.LEFT_PRESS;
					break;
				case "fadeBtn": 
					id = Effect.FADE; 
					break;
				default:
					trace("ERROR:record effect id");
					break;
			}
			sendEffectIDSignal.dispatch(id); 
		}
		
		/**
		 * 
		 * 获取影片起始截取时间
		 * 
		 */  
		private function setRecordBeginBtnClickHandler(e:MouseEvent):void
		{
			getBeginTimeSignal.dispatch();  
			Utils.hideGlow(e.target);
		}
		
		/**
		 * 
		 * 设置按钮滑过、移开特效
		 * 
		 */ 
		private function buttonMouseOverHandler(e:MouseEvent):void
		{
			Utils.showGlow(e.target);
		}
		
		private function buttonMouseOutHandler(e:MouseEvent):void
		{
			Utils.hideGlow(e.target);
		}
		
		/**
		 * 
		 * 获取影片终止截取时间
		 * 
		 */ 
		private function setRecordEndBtnClickHandler(e:MouseEvent):void
		{
			getEndTimeSignal.dispatch(); 
			Utils.hideGlow(e.target);
		}
		
		/**
		 * 影片预览功能
		 */ 
		private function previewBtnClickHandler(e:MouseEvent):void
		{
			previewSignal.dispatch();
			Utils.hideGlow(e.target);
		}
		
		/**
		 * 
		 * 提前停止预览
		 * 
		 */ 
		private function stopPreviewBtnClickHandler(e:MouseEvent):void
		{
			stopPreviewSignal.dispatch();
			Utils.hideGlow(e.target);
		}
		
		/**
		 * 生成XML文档并传送给服务器，清空所有数据，所有改变的状态置为初始状态
		 */ 
		private function  convertBtnClickHandler(e:MouseEvent):void
		{
			convertSignal.dispatch();
			Utils.hideGlow(e.target);
		}
		
		/**
		 * 
		 * @param event 调出操作说明界面
		 * 
		 */		
		private function onBottomTipBarMouseDown(event:MouseEvent):void
		{
			if (_showUserManualLoading == null)
			{
				_showUserManualLoading = new greenLoading();
				_showUserManualLoading.x = mouseX;
				_showUserManualLoading.y = mouseY;
				_showUserManualLoading.scaleX = 0.8;
				_showUserManualLoading.scaleY = 0.8;
				this.addChild(_showUserManualLoading);
				
				_userManualTimer.start();
				_userManualTimer.addEventListener(TimerEvent.TIMER, onUserManualTimerTick);
			}
		}
		
		/**
		 * 
		 * @param event 显示或移除用户操作说明界面
		 * 
		 */		
		private function onUserManualTimerTick(event:TimerEvent):void
		{
			_userManualTimerCounter++;
			if (_userManualTimerCounter >= 5)
			{
				_userManualTimerCounter = 0;
				_userManualTimer.stop();
				_userManualTimer.removeEventListener(TimerEvent.TIMER, onUserManualTimerTick);
				if (_showUserManualLoading!=null)
				{
					if (this.contains(_showUserManualLoading))
					{
						this.removeChild(_showUserManualLoading);
						_showUserManualLoading = null
					}
					
					if (_userManual == null)
					{
						_userManual = new UserManualView();
						_userManual.x = this.videoBG.x + (this.videoBG.width - 436) * 0.5 - 8; // 436为_userManual的最大宽度(其宽度不定)，8为videoBG的修正宽度
						_userManual.y = this.videoBG.y + (this.videoBG.height - _userManual.height) * 0.5 - 14;//14为_userManual的修正高度(其控件高度小于其最大高度)
						this.addChild(_userManual);
					}
					else
					{
						_userManual.play();
						this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
					}
				}
			}
		}
		
		/**
		 * 
		 * @param event 移除用户手册界面
		 * 
		 */		
		protected function onEnterFrame(event:Event):void
		{
			if (_userManual.currentFrame == 50 || _userManual.currentFrame == 100 || _userManual.currentFrame == 150)
			{
				this.removeChild(_userManual);
				_userManual = null;
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		/**
		 * 
		 * @param event 取消调出操作说明界面
		 * 
		 */		
		private function onBottomTipBarMouseUp(event:MouseEvent):void
		{
			if (_showUserManualLoading != null)
			{
				if (this.contains(_showUserManualLoading))
				{
					this.removeChild(_showUserManualLoading);
					_showUserManualLoading = null;
				}
			}
		}
		
		
		/**
		 * 
		 * 更新视频编辑列表状态栏提示信息
		 * 
		 */ 
		public function updateTip(tip:String):void
		{
			_editView.updateText(tip);
		}
		
		/**
		 * 
		 * 预览过程中锁定界面中控件，预览结束后解除锁定
		 * 
		 */ 
		public function lock():void
		{
			Lock.lock(this.videoEditFrame);
			Lock.lock(this.convertBtn);
			Lock.lock(this.setRecordBeginBtn);
			Lock.lock(this.setRecordEndBtn);
			Lock.lock(this._editList); 
			Lock.lock(this._editView); 
		}
		
		public function unlock():void
		{
			Lock.unlock(this.videoEditFrame);
			Lock.unlock(this.convertBtn);
			Lock.unlock(this.setRecordBeginBtn); 
			Lock.unlock(this.setRecordEndBtn);
			Lock.unlock(this._editList);
			Lock.unlock(this._editView);
		}
		
		/**
		 * 
		 * 显示影片转换结果
		 * 
		 */ 
		public function showConvertTip(result:Boolean):void
		{
			if (!_convertTip)
			{
				_convertTip = new ConvertTipView();
				_convertTip.x = this.videoBG.x + (this.videoBG.width - _convertTip.width) * 0.5;
				_convertTip.y = this.videoBG.y + (this.videoBG.height - _convertTip.height) * 0.5;
				this.addChild(_convertTip);
				if (result)
					_convertTip.updateTip(true); 
				else
					_convertTip.updateTip(false);
				_closeConvertTipInterval = setInterval(onTipInterval, 3000);
			}
		}
		
		private function onTipInterval():void
		{
			if (_convertTip)
			{
				if (this.contains(_convertTip))
				{
					this.removeChild(_convertTip);
					_convertTip = null;
					clearInterval(_closeConvertTipInterval);
				}
			}
		}
	
		/**
		 * 
		 * 控制预览按钮、停止预览按钮的显示隐藏
		 * 
		 */ 
		public function previewSetting():void
		{
			this.previewBtn.visible = !this.previewBtn.visible;
			this.stopPreviewBtn.visible = !this.stopPreviewBtn.visible; 	
		}
		
		/**
		 * 
		 * 加载影片地址XML失败，提示用户刷新页面重试
		 * 
		 */		
		public function showLoadXMLErrorTip():void
		{
			if (!_loadXMLErrorTip)
			{
				_loadXMLErrorTip = new GetVideoURLErrorView();
				_loadXMLErrorTip.x = this.videoBG.x + (this.videoBG.width - _loadXMLErrorTip.width) * 0.5;
				_loadXMLErrorTip.y = this.videoBG.y + (this.videoBG.height - _loadXMLErrorTip.height) * 0.5;
				this.addChild(_loadXMLErrorTip);  
			} 
		}
	
		private function showImageUploadTip(result:Boolean):void
		{
			/*if (_uploadTip == null)
			{
				_uploadTip = new UploadTipView();
				result == true ? _uploadTip.uploadResult="图片上传完成" : _uploadTip.uploadResult="图片上传失败";
				
				_uploadTip.x = -180;
				_uploadTip.y = -120;
				this.addChild(_uploadTip);
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}*/
			
			result==true? this.uploadTipTxt.text="图片上传完成" : this.uploadTipTxt.text="图片上传失败";
			this.uploadTipTxt.visible = true;
			
			if (this._closeUploadFlag)
			{
				this._closeUploadFlag = false;
				_closeUploadTipInterval = setInterval(closeUploadTip, 1000);
			}
		}
		
		private function closeUploadTip():void
		{
			this._closeUploadFlag = true;
			this.uploadTipTxt.visible = false;
			clearInterval(_closeUploadTipInterval); 
		}
		
		/*private function removeImageUploadTip():void
		{
			if (_uploadTip)
			{
				if (this.contains(_uploadTip))
				{
					this.removeChild(_uploadTip); 
					_uploadTip = null;
				} 
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (_uploadTip._canRemove)
			{
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				removeImageUploadTip();
			}
		}*/

		/**
		 *
		 * 各控件恢复初始状态 
		 * 
		 */		
		public function clear():void
		{
			initSetting();
			initialize();
			initTitleState();
			comboBoxInit();
			this._fileFolderName = "";
			this._existVideos = [];
			Utils.hideShadow(this.videoEditFrame.videoHeadSearchBtn);
			Utils.hideShadow(this.videoEditFrame.videoTailSearchBtn); 
		}
		
		private function getVideoName(name:String):String
		{
			switch (name)
			{
				case "teacher":
					name = "老师";
					break;
				case "student":
					name = "学生";
					break;
				case "VGA":
					name = "VGA";
					break;
				case "panorama":
					name = "老师全景";
					break;
				case "studentPanorama":
					name = "学生全景";
					break;
				case "blackboard":
					name = "板书";
					break;
				default:
					name = "";
					break;
			}
			return name;
		}
		
		
		/*********************************************************************************************
		 * 变量及监听移除处理
		 *********************************************************************************************/ 
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			_list.push([type,listener,useCapture])
			super.addEventListener(type,listener,useCapture,priority,useWeakReference)
		}
		
		private function destroy(e:Event):void
		{
			if(e.currentTarget != e.target)return;

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
