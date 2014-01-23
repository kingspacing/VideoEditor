package com.editor.view.videoplayer
{
	import com.editor.controller.signals.*;
	import com.editor.model.EditorModel;
	import com.editor.service.VideoService;
	
	import fl.data.DataProvider;
	
	import org.osflash.signals.Signal;
	import org.robotlegs.mvcs.Mediator;
	
	public class VideoPlayerMediator extends Mediator
	{
		[Inject]
		public var view:VideoPlayer;
		
		[Inject]
		public var playVideoSignal:PlayVideoSignal;
		
		[Inject]
		public var changeVolumeSignal:ChangeVolumeSignal;
		
		[Inject]
		public var startVideoPlaySignal:StartVideoPlaySignal;
		
		[Inject]
		public var pauseVideoPlaySignal:PauseVideoPlaySignal;
		
		[Inject]
		public var stopVideoPlaySignal:StopVideoPlaySignal;
		
		[Inject]
		public var loadingBarClickSignal:LoadingBarClickSignal;
		
		[Inject]
		public var loadingBGClickSignal:LoadingBGClickSignal;
		
		[Inject]
		public var playHeadDragSignal:PlayHeadDragSignal;
		
		[Inject]
		public var getBeginTimeSignal:GetBeginTimeSignal;
		
		[Inject]
		public var getEndTimeSignal:GetEndTimeSignal;
		
		[Inject]
		public var sendBeginTimeSignal:SendBeginTimeSignal;
		
		[Inject]
		public var sendEndTimeSignal:SendEndTimeSignal;
		
		[Inject]
		public var previewSignal:PreviewSignal;
		
		[Inject]
		public var lockAllSignal:LockAllSignal;
		
		[Inject]
		public var unlockAllSignal:UnLockAllSignal;
		
		[Inject]
		public var stopPreviewSignal:StopPreviewSignal;
		
		[Inject]
		public var setPreviewStateSignal:SetPreviewStateSignal;
		
		[Inject]
		public var showDataGridCurrentRowBackGroundColorSignal:ShowDataGridCurrentRowBackGroundColorSignal;
		
		[Inject]
		public var hideDataGridCurrentRowBackGroundColorSignal:HideDataGridCurrentRowBackGroundColorSignal;
		
		[Inject]
		public var videoPlayerFineAdjustmentSignal:VideoPlayerFineAdjustmentSignal;
		
		[Inject]
		public var spaceKeyHandlerSignal:SpaceKeyHandlerSignal;
		
		[Inject]
		public var videoService:VideoService;
		
		[Inject]
		public var setVideoURLSignal:SetVideoURLSignal;
		
		[Inject]
		public var networkCheckResultSignal:NetworkCheckResultSignal;
		
		[Inject]
		public var setBeginTimeErrorSignal:SetBeginTimeErrorSignal;
		
		[Inject]
		public var setEndTimeErrorSignal:SetEndTimeErrorSignal;
		
		[Inject]
		public var model:EditorModel;
	
		public function VideoPlayerMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			setVideoURLSignal.add(onSetVideoURLSignal);
			playVideoSignal.add(onPlayVideo);
			
			networkCheckResultSignal.add(onNetworkCheckResultSignal);
			
			changeVolumeSignal.add(onChangeVolumeSignal);
			startVideoPlaySignal.add(onStartVideoPlaySignal);
			pauseVideoPlaySignal.add(onPauseVideoPlaySignal);
			stopVideoPlaySignal.add(onStopVideoPlaySignal);
			loadingBarClickSignal.add(onLoadingBarClickSignal);
			loadingBGClickSignal.add(onLoadingBGClickSignal);
			playHeadDragSignal.add(onPlayHeadDragSignal);
			previewSignal.add(onPreviewSignal);
			stopPreviewSignal.add(onStopPreviewSignal);
			
			getBeginTimeSignal.add(onGetBeginTime);
			getEndTimeSignal.add(onGetEndTime);
			
			videoPlayerFineAdjustmentSignal.add(onVideoPlayerFineAdjustmentSignal);
			spaceKeyHandlerSignal.add(onSpaceKeyHandlerSignal);
			
			setBeginTimeErrorSignal.add(onSetBeginTimeErrorSignal);
			setEndTimeErrorSignal.add(onSetEndTimeErrorSignal);
			
		
			view.sendBeginTimeSignal.add(onSendBeginTime);
			view.sendEndTimeSignal.add(onSendEndTime);
			view.lockAllSignal.add(onLockSignal);
			view.unlockAllSignal.add(onUnlockSignal);
			
			view.showCurrentRowColor.add(onShowCurrentRowColor);
			view.hideCurrentRowColor.add(onHideCurrentRowColor);
			view.setPreviewStateSignal.add(onSetPreviewStateSignal);
			
			//videoService.getVideoURL();
			
		}
		
		/**
		 *
		 * 插入终止时间出错提示 
		 * 
		 */		
		private function onSetEndTimeErrorSignal():void
		{
			view.showInsertEndTimeTip();
		}
		
		/**
		 *
		 * 插入起始时间出错提示
		 * 
		 */		
		private function onSetBeginTimeErrorSignal():void
		{
			view.showInsertBeginTimeTip();
		}		
		
		/**
		 *
		 * 键盘空格事件处理 
		 * 
		 */		
		private function onSpaceKeyHandlerSignal():void
		{
			view.spaceKeyEventHandler();
		}
		
		/**
		 * 
		 * @param direction : 播放时间微调
		 * 
		 */		
		private function onVideoPlayerFineAdjustmentSignal(direction:String):void
		{
			view.updateCurrentPlayPosition(direction);
		}
		
		/**
		 * 
		 * @param result ：显示网络状态监测结果
		 * 
		 */		
		private function onNetworkCheckResultSignal(result:Boolean):void
		{
			view.showNetworkTip(result);
		}
		
		/**
		 * 
		 * @param urls ：将获取的XML文件中影片地址传入
		 * 
		 */		
		private function onSetVideoURLSignal(urls:Array, rtmp:String):void
		{
			view.urls = urls;
			view.rtmp = rtmp;
		}
		
		/**
		 *
		 * 停止预览 
		 * 
		 */		
		private function onStopPreviewSignal():void
		{
			view.stopPreview();
		}
		
		/**
		 * 
		 * @param o ：当前操作数据项
		 * 预览过程中给编辑列表中当前数据项添加选中效果
		 * 
		 */		
		private function onShowCurrentRowColor(o:Object):void
		{
			showDataGridCurrentRowBackGroundColorSignal.dispatch(o);
		}
		
		/**
		 * 
		 * @param o ：同上
		 * 移除播放完成的数据项的选中效果
		 * 
		 */		
		private function onHideCurrentRowColor(o:Object):void
		{
			hideDataGridCurrentRowBackGroundColorSignal.dispatch(o);
		}
		
		/**
		 *
		 *  用户选择提前停止预览或者预览完成后设置影片预览与停止预览按钮的当前显示状态
		 * 
		 */		
		private function onSetPreviewStateSignal():void
		{
			setPreviewStateSignal.dispatch();
		}
		
		/**
		 *
		 * 锁定界面 
		 * 
		 */		
		private function onLockSignal():void
		{
			lockAllSignal.dispatch();
		}
		
		/**
		 *
		 * 解除界面锁定 
		 * 
		 */		
		private function onUnlockSignal():void
		{
			unlockAllSignal.dispatch();
		}
	
		/**
		 *
		 * 开始影片预览 
		 * 
		 */		
		private function onPreviewSignal():void
		{
			view.dataprovider = model.dataprovider; 
		}
		
		/**
		 * 
		 * @param data ：各路影片地址
		 * 开始播放该路视频
		 * 
		 */		
		private function onPlayVideo(data:String):void
		{
			model.isCanSeek = true; //判定当前进度条是否接受seek
			view.model = model;
			view.videoURL = data; 
		}
		
		/**
		 * 
		 * @param volume ：音量数据
		 * 调节影片播放音量
		 * 
		 */		
		private function onChangeVolumeSignal(volume:Number):void
		{
			view.volume = volume;
		}
		
		/**
		 *
		 * 播放控制条中播放按钮点击事件处理 
		 * 
		 */		
		private function onStartVideoPlaySignal():void
		{
			view.play();
		}
		
		/**
		 *
		 * 播放控制条中暂停按钮点击事件处理  
		 * 
		 */		
		private function onPauseVideoPlaySignal():void
		{
			view.pause();
		}
		
		/**
		 *
		 * 播放控制条中停止按钮点击事件处理  
		 * 
		 */		
		private function onStopVideoPlaySignal():void
		{
			view.stop();
		}
		
		/**
		 * 
		 * @param position ：用户选择跳转的位置占整个进度条的百分比
		 * 
		 */		
		private function onLoadingBarClickSignal(position:Number):void
		{
			view.seek(position);
		}
		
		/**
		 * 
		 * @param position ：同上
		 * 跳转播放
		 * 
		 */		
		private function onLoadingBGClickSignal(position:Number):void
		{
			view.seek(position);
		}
		
		/**
		 * 
		 * @param position
		 * 播放头拖动操作处理
		 * 
		 */		
		private function onPlayHeadDragSignal(position:Number):void
		{
			view.seek(position);
		}
		
		/**
		 *
		 * 获取起始记录时间 
		 * 
		 */		
		private function onGetBeginTime():void
		{
			view.getBeginTime();
		}
		
		/**
		 *
		 * 获取终止记录时间 
		 * 
		 */		
		private function onGetEndTime():void
		{
			view.getEndTime();
		}
		
		/**
		 * 
		 * @param o ：起始时间信息
		 * 
		 */		
		private function onSendBeginTime(o:Object):void
		{
			sendBeginTimeSignal.dispatch(o);
		}
		
		/**
		 * 
		 * @param o ：终止时间信息
		 * 
		 */		
		private function onSendEndTime(o:Object):void
		{
			sendEndTimeSignal.dispatch(o);
		}
		
		override public function onRemove():void
		{
			setVideoURLSignal.remove(onSetVideoURLSignal);
			playVideoSignal.remove(onPlayVideo);
			networkCheckResultSignal.remove(onNetworkCheckResultSignal);
			changeVolumeSignal.remove(onChangeVolumeSignal);
			startVideoPlaySignal.remove(onStartVideoPlaySignal);
			pauseVideoPlaySignal.remove(onPauseVideoPlaySignal);
			stopVideoPlaySignal.remove(onStopVideoPlaySignal);
			loadingBarClickSignal.remove(onLoadingBarClickSignal);
			loadingBGClickSignal.remove(onLoadingBGClickSignal);
			playHeadDragSignal.remove(onPlayHeadDragSignal);
			previewSignal.remove(onPreviewSignal);
			stopPreviewSignal.remove(onStopPreviewSignal);
			
			getBeginTimeSignal.remove(onGetBeginTime);
			getEndTimeSignal.remove(onGetEndTime);
			
			videoPlayerFineAdjustmentSignal.remove(onVideoPlayerFineAdjustmentSignal);
			spaceKeyHandlerSignal.remove(onSpaceKeyHandlerSignal);
			
			view.sendBeginTimeSignal.remove(onSendBeginTime);
			view.sendEndTimeSignal.remove(onSendEndTime);
			view.lockAllSignal.remove(onLockSignal);
			view.unlockAllSignal.remove(onUnlockSignal);
			
			view.showCurrentRowColor.remove(onShowCurrentRowColor);
			view.hideCurrentRowColor.remove(onHideCurrentRowColor);
			view.setPreviewStateSignal.remove(onSetPreviewStateSignal);
		}
	}
}
