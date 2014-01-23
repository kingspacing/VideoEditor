package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import org.osflash.signals.natives.NativeSignal;

	public class VideoEditor extends Sprite
	{
		private var context:VideoEditorContext;	
		
		
		public function VideoEditor()
		{
			if (stage)
			{
				addToStage(null);    
			}
			else
			{
				var addSignal:NativeSignal = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			}
		}
		
		private function addToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addToStage);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.displayState = StageDisplayState.NORMAL;
			stage.frameRate = 48; 
			context = new VideoEditorContext(this, true);
		}
	}
}
