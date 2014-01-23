package com.editor.view.editlist
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;

	public class EditView extends AddDeleteUI
	{
		public var insertSignal:Signal;
		public var deleteSignal:Signal; 
		private var _list:Array =  new Array();
		
		public function EditView()
		{
			super();
			init();
		}		
		
		/**
		 * 控件说明
		 * insertBtn：插入按钮；
		 * deleteBtn：删除按钮；
		 * tipTxt：提示文本框；
		 */
		private function init():void
		{
			this.insertSignal = new Signal();
			this.deleteSignal = new Signal();
			this.insertBtn.addEventListener(MouseEvent.CLICK, onInsertBtnMouseClick); 
			this.insertBtn.addEventListener(MouseEvent.MOUSE_OVER, onInsertBtnMouseOver);
			this.insertBtn.addEventListener(MouseEvent.MOUSE_OUT, onInsertBtnMouseOut);
			this.deleteBtn.addEventListener(MouseEvent.CLICK, onDeleteBtnMouseClick);
			this.deleteBtn.addEventListener(MouseEvent.MOUSE_OVER, onDeleteBtnMouseOver);
			this.deleteBtn.addEventListener(MouseEvent.MOUSE_OUT, onDeleteBtnMouseOut);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function onInsertBtnMouseClick(event:MouseEvent):void
		{
			insertSignal.dispatch();
		}
		
		private function onInsertBtnMouseOver(event:MouseEvent):void
		{
			tipTxt.text = "在选中位置后添加一行数据";
		}
		
		private function onInsertBtnMouseOut(event:MouseEvent):void
		{
			tipTxt.text = "";
		}
		
		private function onDeleteBtnMouseClick(event:MouseEvent):void
		{
			deleteSignal.dispatch();
		}
		
		private function onDeleteBtnMouseOver(event:MouseEvent):void
		{
			tipTxt.text = "删除选中的数据";  
		}
		
		private function onDeleteBtnMouseOut(event:MouseEvent):void
		{
			tipTxt.text = "";
		}
	
		public function updateText(text:String):void
		{
			this.tipTxt.text = text; 
		}
		
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
