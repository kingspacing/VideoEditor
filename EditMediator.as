package com.editor.view.editlist
{
	import com.editor.controller.signals.SendDeleteSignal;
	import com.editor.controller.signals.SendInsertSignal;
	import com.editor.model.EditorModel;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditMediator extends Mediator
	{
		[Inject]
		public var v:EditView;
		
		[Inject]
		public var insertSignal:SendInsertSignal;
		
		[Inject]
		public var deleteSignal:SendDeleteSignal;
		
		[Inject]
		public var m:EditorModel;
		
		public function EditMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			v.insertSignal.add(onInsert);
			v.deleteSignal.add(onDelete);
		}
		
		private function onInsert():void
		{
			if (m.currentSelectedItems == null)
			{
				v.updateText("请正确选择插入位置"); 
			}
			else
			{
				if (m.currentSelectedItems.length > 1 || m.currentSelectedItems.length == 0)
				{
					v.updateText("请正确选择插入位置");
				}
				else 
				{
					v.updateText("请设置起始时间和终止时间");
				}
			}
			
			insertSignal.dispatch();
		}
		
		private function onDelete():void
		{
			if (m.currentSelectedItems == null || m.dataprovider == null)
			{
				v.updateText("请选择需要删除的数据项");
			}
			deleteSignal.dispatch();
		}
		
		override public function onRemove():void
		{
			v.insertSignal.remove(onInsert);
			v.deleteSignal.remove(onDelete);
		}
	}
}
