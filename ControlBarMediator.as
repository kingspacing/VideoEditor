package com.editor.view.videoplayer
{
	import com.editor.controller.signals.ChangeVolumeSignal;
	import com.editor.controller.signals.LoadingBGClickSignal;
	import com.editor.controller.signals.LoadingBarClickSignal;
	import com.editor.controller.signals.PauseVideoPlaySignal;
	import com.editor.controller.signals.PlayHeadDragSignal;
	import com.editor.controller.signals.StartVideoPlaySignal;
	import com.editor.controller.signals.StopVideoPlaySignal;
	import com.editor.controller.signals.VideoPlayerFineAdjustmentSignal;
	import com.editor.model.EditorModel;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ControlBarMediator extends Mediator
	{
		[Inject]
		public var view:ControlBar;
		
		[Inject]
		public var model:EditorModel;
		
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
		public var videoPlayerFineAdjustmentSignal:VideoPlayerFineAdjustmentSignal;
		
		public function ControlBarMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			view.changeVolumeSignal.add(onVolumeChange);
			view.startVideoPlaySignal.add(onStartVideoPlaySignal);
			view.pauseVideoPlaySignal.add(onPauseVideoPlaySignal);
			view.stopVideoPlaySignal.add(onStopVideoPlaySignal);
			view.loadingBarClickSignal.add(onLoadingBarClickSignal);
			view.loadingBGClickSignal.add(onLoadingBGClickSignal);
			view.playHeadDragSignal.add(onPlayHeadDragSignal);
			view.videoPlayerFineAdjustmentSignal.add(onVideoPlayerFineAdjustmentSignal);
		}
		
		/**
		 * 
		 * @param direction : 用户按下的按键(向左键/向右键)
		 * 通过键盘微调当前播放影片播放位置
		 * 
		 */		
		private function onVideoPlayerFineAdjustmentSignal(direction:String):void
		{
			videoPlayerFineAdjustmentSignal.dispatch(direction); 
		}
		
		private function onVolumeChange(volume:Number):void
		{
			changeVolumeSignal.dispatch(volume);
		}
		
		private function onStartVideoPlaySignal():void
		{
			startVideoPlaySignal.dispatch();
		}
		
		private function onPauseVideoPlaySignal():void
		{
			pauseVideoPlaySignal.dispatch();
		}
		
		private function onStopVideoPlaySignal():void
		{
			stopVideoPlaySignal.dispatch();
		}
		
		private function onLoadingBarClickSignal(position:Number):void
		{
			if (model.isCanSeek){
				view.updateLoadingBarByMouseClick();
			}else{
				return;
			}
			
			loadingBarClickSignal.dispatch(position);
		}
		
		private function onLoadingBGClickSignal(position:Number):void
		{
			if (model.isCanSeek){
				view.updateLoadingBGByMouseClick();
			}else{
				return;
			}
				
			loadingBGClickSignal.dispatch(position);
		}
		
		private function onPlayHeadDragSignal(position:Number):void
		{
			/*if (model.isCanSeek){
				view.updatePosition();
			}else{
				return;
			}
			
			playHeadDragSignal.dispatch(position);*/
		}
		
		override public function onRemove():void
		{
			view.changeVolumeSignal.remove(onVolumeChange);
			view.startVideoPlaySignal.remove(onStartVideoPlaySignal);
			view.pauseVideoPlaySignal.remove(onPauseVideoPlaySignal);
			view.stopVideoPlaySignal.remove(onStopVideoPlaySignal);
			view.loadingBarClickSignal.remove(onLoadingBarClickSignal);
			view.loadingBGClickSignal.remove(onLoadingBGClickSignal);
			view.playHeadDragSignal.remove(onPlayHeadDragSignal);
			view.videoPlayerFineAdjustmentSignal.remove(onVideoPlayerFineAdjustmentSignal);
		}
	}
}
