package
{
	import com.editor.controller.command.*;
	import com.editor.controller.signals.*;
	import com.editor.model.*;
	import com.editor.service.*;
	import com.editor.view.*;
	import com.editor.view.editlist.*;
	import com.editor.view.tip.*;
	import com.editor.view.videoplayer.*;
	import com.editor.view.videoplayer.network.*;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.mvcs.SignalContext;
	
	public class VideoEditorContext extends SignalContext
	{
		public function VideoEditorContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
		{
			super(contextView, autoStartup);
		}
		
		override public function startup():void
		{
			/*--------------------------------------------------------------*/
			
			//影片播放微调
			injector.mapSingleton(VideoPlayerFineAdjustmentSignal);
			
			//提示信息
			injector.mapSingleton(NetworkCheckResultSignal);
			injector.mapSingleton(SetBeginTimeErrorSignal);
			injector.mapSingleton(SetEndTimeErrorSignal);
			
			
			//获取影片地址
			injector.mapSingleton(SetVideoURLSignal);
			injector.mapSingleton(LoadVideoURLXMLFailedSignal);
			injector.mapSingleton(UpdatePlayButtonStateSignal);
			
			//播放器功能控制
			injector.mapSingleton(PlayVideoSignal);
			injector.mapSingleton(ChangeVolumeSignal);
			injector.mapSingleton(StartVideoPlaySignal);
			injector.mapSingleton(PauseVideoPlaySignal);
			injector.mapSingleton(StopVideoPlaySignal);
			injector.mapSingleton(LoadingBarClickSignal);
			injector.mapSingleton(LoadingBGClickSignal);
			injector.mapSingleton(PlayHeadDragSignal);
			injector.mapSingleton(SpaceKeyHandlerSignal);
			
			//编辑列表控制
			injector.mapSingleton(GetBeginTimeSignal);
			injector.mapSingleton(GetEndTimeSignal);
			injector.mapSingleton(SendBeginTimeSignal);
			injector.mapSingleton(SendEndTimeSignal); 
			injector.mapSingleton(SendInsertSignal);
			injector.mapSingleton(SendDeleteSignal);
			injector.mapSingleton(SendInsertSuccessSignal);
			injector.mapSingleton(SendDeleteSuccessSignal);
			injector.mapSingleton(DeleteAllEditListDataSignal);
			
			//影片预览功能
			injector.mapSingleton(PreviewSignal);
			injector.mapSingleton(LockAllSignal);
			injector.mapSingleton(UnLockAllSignal);
			injector.mapSingleton(SetPreviewStateSignal);
			injector.mapSingleton(StopPreviewSignal);
			injector.mapSingleton(RemoveSelectedEffectSignal);
			injector.mapSingleton(ShowDataGridCurrentRowBackGroundColorSignal);
			injector.mapSingleton(HideDataGridCurrentRowBackGroundColorSignal);
			
			//影片转换
			
			/*--------------------------------------------------------------*/
			
			//注入service
			injector.mapSingleton(VideoService); 
			
			/*---------------------------------------------------------------*/
			
			signalCommandMap.mapSignalClass(StartupSignal, StartUpCommand); 
			
			/*---------------------------------------------------------------*/
			mediatorMap.mapView(MainView, MainMediator);
			mediatorMap.mapView(VideoPlayer, VideoPlayerMediator);
			mediatorMap.mapView(ControlBar, ControlBarMediator);
			mediatorMap.mapView(TimeTipView, TimeTipMediator);   
			mediatorMap.mapView(ConvertTipView, ConvertTipMediator);
			mediatorMap.mapView(EditListView, EditListMediator);
			mediatorMap.mapView(EditView, EditMediator);
			mediatorMap.mapView(NetworkCheckView, NetworkCheckMediator);
			/*-------------------------------------------------------------*/
			
			//注入model
			injector.mapSingleton(EditorModel);
			
			
			onCompleteBootstrap();
		}
		
		private function onCompleteBootstrap() : void
		{
			var signal:StartupSignal = injector.getInstance(StartupSignal);
			signal.dispatch();
		}
	}
}
