package com.editor.view
{
	import com.editor.controller.common.Convert;
	import com.editor.controller.common.Upload;
	import com.editor.controller.signals.*;
	import com.editor.model.EditorModel;
	import com.editor.service.VideoService;
	
	import fl.data.DataProvider;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.osmf.media.DefaultMediaFactory;
	import org.robotlegs.mvcs.Mediator;
	
	public class MainMediator extends Mediator
	{
		[Inject]
		public var mv:MainView;
		
		[Inject]
		public var model:EditorModel; 
		
		[Inject]
		public var playVideoSignal:PlayVideoSignal;
		
		[Inject]
		public var getBeginTimeSignal:GetBeginTimeSignal;
		
		[Inject]
		public var getEndTimeSignal:GetEndTimeSignal;
		
		[Inject]
		public var sendDeleteSuccessSignal:SendDeleteSuccessSignal;
		
		[Inject]
		public var sendInsertSuccessSignal:SendInsertSuccessSignal;
		
		[Inject]
		public var lockAllSignal:LockAllSignal;
		
		[Inject]
		public var unlockAllSignal:UnLockAllSignal;
		
		[Inject]
		public var previewSignal:PreviewSignal;
		
		[Inject]
		public var stopPreviewSignal:StopPreviewSignal;
		
		[Inject]
		public var setPreviewStateSignal:SetPreviewStateSignal;
		
		[Inject]
		public var removeSelectedEffectSignal:RemoveSelectedEffectSignal;
		
		[Inject]
		public var updatePlayButtonStateSignal:UpdatePlayButtonStateSignal;
		
		[Inject]
		public var loadVideoURLXMLFailedSignal:LoadVideoURLXMLFailedSignal;
		
		[Inject]
		public var deleteAllEditListDataSignal:DeleteAllEditListDataSignal;
		
		[Inject]
		public var setVideoURLSignal:SetVideoURLSignal;
		
		
		
		private var _uploadRequest:URLRequest;
		
		public function MainMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			mv.playVideoSignal.add(onPlayVideoSignal); 
			mv.getBeginTimeSignal.add(onGetBeginTimeSignal);
			mv.getEndTimeSignal.add(onGetEndTimeSignal); 
			mv.sendFilmBeginPathSignal.add(onSendFilmBeginImageSignal);
			mv.sendFilmEndPathSignal.add(onSendFilmEndImageSignal);
			mv.sendEffectIDSignal.add(onSendEffectIDSignal);
			mv.previewSignal.add(onPreviewSignal);
			mv.stopPreviewSignal.add(onStopPreviewSignal);
			mv.convertSignal.add(onConvertSignal);
			mv.setHeadCheckSelectedStateSignal.add(onSetHeadCheckSelectedStateSignal);
			mv.setTailCheckSelectedStateSignal.add(onSetTailCheckSelectedStateSginal);
			mv.setHeadImageDurationSignal.add(onSetHeadImageDurationSignal);
			mv.setTailImageDurationSignal.add(onSetTailImageDurationSignal);
			mv.setVideoURLSignal.add(onSetVideoURLSignal);
			
			sendDeleteSuccessSignal.add(onSendDeleteSuccessSignal);
			sendInsertSuccessSignal.add(onSendInsertSuccessSignal);
			lockAllSignal.add(onLockAllSignal);
			unlockAllSignal.add(onUnlockAllSignal);
			setPreviewStateSignal.add(onSetPreviewStateSignal);
			updatePlayButtonStateSignal.add(onUpdatePlayButtonStateSignal);
			loadVideoURLXMLFailedSignal.add(onLoadVideoURLXMLFailedSignal);
		}
		
		private function onSetVideoURLSignal(urls:Array, rtmp:String):void
		{
			setVideoURLSignal.dispatch(urls, rtmp);
		}		
				
		/**
		 * 
		 * @param duration : 片尾图片持续时长
		 * 
		 */		
		private function onSetTailImageDurationSignal(duration:uint):void
		{
			model.filmStartDuration = duration;
		}
		
		/**
		 * 
		 * @param duration ：片头图片持续时长
		 * 
		 */		
		private function onSetHeadImageDurationSignal(duration:uint):void
		{
			model.filmEndDuration = duration;
		}		
		
		/**
		 * 
		 * @param state : 是否添加片头图片
		 * 
		 */		
		private function onSetHeadCheckSelectedStateSignal(state:String):void
		{
			model.filmStartAdd = state;
		}
		
		/**
		 * 
		 * @param state ：是否添加片尾图片
		 * 
		 */		
		private function onSetTailCheckSelectedStateSginal(state:String):void
		{
			model.filmEndAdd = state;
		}
		
		/**
		 *
		 * 加载影片地址XML文件失败给出提示信息 
		 * 
		 */		
		private function onLoadVideoURLXMLFailedSignal():void
		{
			mv.showLoadXMLErrorTip();
		}
		
		/**
		 * 
		 * @param urls ：各路影片地址
		 * 根据该路是否有影片地址更新播放按钮当前状态
		 * 有视频则为绿色按钮否则为灰色按钮
		 * 
		 */		
		private function onUpdatePlayButtonStateSignal(urls:Array):void
		{
			mv.updatePlayBtnState(urls);
		}
		
		/**
		 *
		 * 根据影片编辑列表中数据项生成播放列表并上传到服务器 
		 * 上传完成后清空编辑列表
		 * 
		 */		
		private function onConvertSignal():void
		{
		
			if (model.dataprovider)
			{
				if (model.dataprovider.length < 1)
				{
					return;
				}
				else
				{
					var _dp:DataProvider = new DataProvider();
					var _modelDP:DataProvider = model.dataprovider;
					var _len:int = model.dataprovider.length;
					for (var i:int=0; i < _len; i++)
					{
						var o:Object = new Object();
						if (_modelDP.getItemAt(i).影片名称 == "老师") o.影片名称 = "teacher";
						else if (_modelDP.getItemAt(i).影片名称 == "学生") o.影片名称 = "student";			
						else if (_modelDP.getItemAt(i).影片名称 == "VGA") o.影片名称 = "VGA";						
						else if (_modelDP.getItemAt(i).影片名称 == "老师全景") o.影片名称 = "panorama";						
						else if (_modelDP.getItemAt(i).影片名称 == "学生全景") o.影片名称 = "studentPanorama";						
						else if (_modelDP.getItemAt(i).影片名称 == "板书") o.影片名称 = "blackboard";						
						o.起始时间 = _modelDP.getItemAt(i).起始时间;
						o.终止时间 = _modelDP.getItemAt(i).终止时间;
						_dp.addItem(o);
						
						//检测当前是否记录了该路视频
						checkRecord(o); 
					}
				}	
			}
			else
			{ 
				return;
			}
			
			var path:Array = new Array();
			var videos:Array = mv._videoURLs; 
			var flag:Boolean = false;
			for (var j:int=0; j < videos.length; j++)
			{
				if (!videos[j].exist)
					continue;
				var obj:Object = new Object();
				obj.id = videos[j].id;
				obj.audio = "NO";				
				obj.path = String(videos[j].url).substring(4);
				path.push(obj); 
			}
			path = updatePathAudio(path);
				
			var filmInfo:Object = new Object();
			var filmStart:Object = new Object();
			var filmEnd:Object = new Object();
			filmStart.add = model.filmStartAdd;
			filmStart.duration = model.filmStartDuration;
			filmStart.path = model.filmStartPath;
			
			filmEnd.add = model.filmEndAdd;
			filmEnd.duration = model.filmEndDuration;
			filmEnd.path = model.filmEndPath;
			
			filmInfo.filmStart = filmStart;
			filmInfo.filmEnd = filmEnd;
			
			var transEffect:uint = model.transEffect;
			var xml:XML =  Convert.convert(_dp,path,filmInfo, transEffect);
			
			trace (xml);
			
			var variables:URLVariables = new URLVariables();
			if (mv._fileFolderName){
				variables.path = String(mv._fileFolderName + "/editlist.xml");
			}else{
				variables.path = String(Convert.targetName + "/editlist.xml");
			}
			variables.type = "xml";
			variables.data = String(xml);
			
			_uploadRequest = new URLRequest();
			_uploadRequest.url= Upload.XML_UPLOAD_URL;
			_uploadRequest.method = URLRequestMethod.POST ;
			_uploadRequest.data = variables; 
		
			var loader:URLLoader=new URLLoader();  
			loader.addEventListener(Event.COMPLETE,onCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			loader.addEventListener(ProgressEvent.PROGRESS,onProgress);
			loader.load(_uploadRequest);
		}
	
		private function checkRecord(o:Object):void
		{
			var len:int = mv._videoURLs.length;
			for (var i:int=0; i<len; i++)
			{
				if (mv._videoURLs[i].id == o.影片名称)
				{
					mv._videoURLs[i].exist = true;
					return;
				}
			}
		}
		
		private function updatePathAudio(path:Array):Array
		{
			for (var i:int=0; i<path.length; i++)
			{
				if (path[i].id == "teacher")
				{
					path[i].audio = "YES";
					return path;
				}
			}
			path[Math.round(Math.random() * (path.length - 1))].audio = "YES";
			return path;
		}
		
		protected function onCompleteHandler(event:Event):void
		{
			trace ("文件内容为：" + event.target.data);
			deleteAllEditListDataSignal.dispatch();
			mv.clear();
			mv.showConvertTip(true); 
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			trace ("securityError:" + event);
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
			trace ("IOError:" + event);
			mv.showConvertTip(false);
			
			//deleteAllEditListDataSignal.dispatch();
			//mv.clear();	
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			trace ("upload progress :" + (event.bytesLoaded / event.bytesTotal * 100) + "%");
		}
		
		/**
		 * 
		 * @param name ：该路影片名称
		 * 播放该路视频
		 * 
		 */		
		private function onPlayVideoSignal(name:String):void
		{
			trace(this,name);
			playVideoSignal.dispatch(name); 
		}
		
		/**
		 * 
		 * @param msg ：插入数据项成功
		 * 
		 */		
		private function onSendInsertSuccessSignal(msg:String):void
		{
			mv.updateTip(msg);
		}
		
		/**
		 * 
		 * @param msg ：删除编辑列表数据项成功
		 * 
		 */		
		private function onSendDeleteSuccessSignal(msg:String):void
		{
			mv.updateTip(msg);
		}
		
		/**
		 *
		 * 获取当前影片起始记录时间 
		 * 
		 */		
		private function onGetBeginTimeSignal():void
		{
			getBeginTimeSignal.dispatch();
		}
		
		/**
		 *
		 * 获取当前影片的终止记录时间 
		 * 
		 */		
		private function onGetEndTimeSignal():void
		{
			getEndTimeSignal.dispatch();
		}
		
		/**
		 * 
		 * @param o ：片头图片信息
		 * 
		 */		
		private function onSendFilmBeginImageSignal(path:String):void
		{
			model.filmStartPath = path;  
		}
		
		/**
		 * 
		 * @param o ：片尾图片信息
		 * 
		 */		
		private function onSendFilmEndImageSignal(path:String):void
		{
			model.filmEndPath = path; 
		}
		
		/**
		 * 
		 * @param id ：用户选取的转场特效ID
		 * 
		 */		
		private function onSendEffectIDSignal(id:uint):void
		{
			model.transEffect = id;
		}
		
		/**
		 *
		 * 发送影片预览信息开始影片预览 
		 * 
		 */		
		private function onPreviewSignal():void
		{
			if (model.dataprovider)
			{
				if (model.dataprovider.length >= 1)
				{
					mv.previewSetting();
					removeSelectedEffectSignal.dispatch();
					previewSignal.dispatch(); 
				}
			}
		}
		
		/**
		 *
		 * 停止影片预览 
		 * 
		 */		
		private function onStopPreviewSignal():void
		{
			if (model.dataprovider)
			{
				if (model.dataprovider.length >= 1)
				{
					mv.previewSetting();
					stopPreviewSignal.dispatch();
				}
			}
		}
		
		/**
		 *
		 * 设置影片预览与停止预览按钮的显示状态
		 * 
		 */		
		private function onSetPreviewStateSignal():void
		{
			mv.previewSetting(); 
		}
		
		/**
		 *
		 * 预览开始后锁定软件中其他界面操作(影片预览、停止预览按钮除外) 
		 * 
		 */		
		private function onLockAllSignal():void
		{
			mv.lock();
		}
		
		/**
		 *
		 *  预览完成或提前停止预览后解锁界面
		 * 
		 */		
		private function onUnlockAllSignal():void
		{
			mv.unlock();
		}
		
		override public function onRemove():void
		{
			mv.playVideoSignal.remove(onPlayVideoSignal); 
			mv.getBeginTimeSignal.remove(onGetBeginTimeSignal);
			mv.getEndTimeSignal.remove(onGetEndTimeSignal); 
			mv.sendFilmBeginPathSignal.remove(onSendFilmBeginImageSignal);
			mv.sendFilmEndPathSignal.remove(onSendFilmEndImageSignal);
			mv.sendEffectIDSignal.remove(onSendEffectIDSignal);
			mv.previewSignal.remove(onPreviewSignal);
			mv.stopPreviewSignal.remove(onStopPreviewSignal);
			mv.convertSignal.remove(onConvertSignal);
			mv.setHeadCheckSelectedStateSignal.remove(onSetHeadCheckSelectedStateSignal);
			mv.setTailCheckSelectedStateSignal.remove(onSetTailCheckSelectedStateSginal);
			mv.setHeadImageDurationSignal.remove(onSetHeadImageDurationSignal);
			mv.setTailImageDurationSignal.remove(onSetTailImageDurationSignal);
			
			sendDeleteSuccessSignal.remove(onSendDeleteSuccessSignal);
			sendInsertSuccessSignal.remove(onSendInsertSuccessSignal);
			lockAllSignal.remove(onLockAllSignal);
			unlockAllSignal.remove(onUnlockAllSignal);
			setPreviewStateSignal.remove(onSetPreviewStateSignal);
			updatePlayButtonStateSignal.remove(onUpdatePlayButtonStateSignal);
			loadVideoURLXMLFailedSignal.remove(onLoadVideoURLXMLFailedSignal);
		}
	}
}
