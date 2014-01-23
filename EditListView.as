package com.editor.view.editlist
{
	import com.editor.controller.utils.TimeUtil;
	import com.editor.style.*;
	
	import fl.controls.DataGrid;
	import fl.controls.dataGridClasses.*;
	import fl.controls.listClasses.CellRenderer;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	public class EditListView extends Sprite
	{
		private var dg:DataGrid;
		private var _dataProvider:DataProvider = new DataProvider();
		private var _realDataProvider:DataProvider = new DataProvider();
		private var _bg:Sprite;
		private var NameColumn:DataGridColumn
		private var BeginTimeColumn:DataGridColumn;
		private var EndTimeColumn:DataGridColumn;
		private var _list:Array = new Array();
		public var listItemClickSignal:Signal;
		
		public var listItemArray:DataProvider = new DataProvider();
		
		
		private var _isShiftKeyDown:Boolean = false;
		private var _isCtrlKeyDown:Boolean = false;
	
		public function EditListView()
		{
			super();
			init();
		}
		
		private function init():void
		{
			dg = new DataGrid();
			dg.setSize(219,302);
			dg.resizableColumns = false;
			dg.rowHeight = 20;
			dg.editable = false;
			dg.allowMultipleSelection = true;
			
			
			NameColumn = new DataGridColumn("影片名称");
			BeginTimeColumn = new DataGridColumn("起始时间");
			EndTimeColumn = new DataGridColumn("终止时间");
			dg.addColumn(NameColumn);
			dg.addColumn(BeginTimeColumn);  
			dg.addColumn(EndTimeColumn);
			dg.minColumnWidth = dg.width / 3;
			dg.setStyle("headerRenderer", DatagridHeaderStyle);
			dg.setStyle("cellRenderer", DatagridCellStyle);
			NameColumn.cellRenderer = DatagridNameCellStyle;
			dg.dataProvider = dataProvider;
			this.addChild(dg);

			dg.addEventListener(ListEvent.ITEM_ROLL_OVER, onRollOver);
			dg.addEventListener(ListEvent.ITEM_ROLL_OUT, onRollOut);
			dg.addEventListener(ListEvent.ITEM_CLICK, onItemClick);
			dg.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown); 
			dg.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			listItemClickSignal = new Signal(DataProvider);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.shiftKey){
				event.preventDefault();
				event.stopImmediatePropagation();
				event.stopPropagation();
				this._isShiftKeyDown = true;
			}
			
			if (event.ctrlKey){
				this._isCtrlKeyDown = true;
			}
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == 16) //shift按键
			{
				this._isShiftKeyDown = false;
			}
			else if (event.keyCode == 17)//ctrl按键
			{
				this._isCtrlKeyDown = false; 
			}
				
		}
		
		public function showCurrentRowColor(o:Object):void
		{
			var _rowIndex:int = 0;
			for (var i:int=0; i < dataProvider.length; i++)
			{
				if (o == realDataProvider.getItemAt(i))
				{
					_rowIndex = i;
					break;
				}
			}
			
			var event:ListEvent = new ListEvent(ListEvent.ITEM_ROLL_OVER,false,false,-1,_rowIndex,_rowIndex,o);  
			dg.dispatchEvent(event);
		}
		
		public function hideCurrentRowColor(o:Object):void
		{
			var _rowIndex:int = 0;
			for (var i:int=0; i < dataProvider.length; i++)
			{
				if (o == realDataProvider.getItemAt(i))
				{
					_rowIndex = i;
					break;
				}
			}
			
			var event:ListEvent = new ListEvent(ListEvent.ITEM_ROLL_OUT,false,false,-1,_rowIndex,-1,o); 
			dg.dispatchEvent(event);
		}
		
		private function onItemClick(event:ListEvent):void
		{
			if (this._isShiftKeyDown)
			{
				event.stopPropagation();
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
			}
			
			var _isItemExist:Boolean = false;
			var index:uint = searchForTheIndexFromDataProvider(event.item);
			
			try
			{
				if (this._isCtrlKeyDown)
				{
					if (listItemArray)
					{
						if (listItemArray.length > 0)
						{
							for (var i:int=0; i<listItemArray.length; i++)
							{
								if (listItemArray.getItemAt(i) == realDataProvider.getItemAt(index))
								{
									_isItemExist = true;
									break;
								}
							}
							
							if (_isItemExist)
							{
								listItemArray.removeItem(realDataProvider.getItemAt(index));
								_isItemExist = false;
							}
							else
							{
								listItemArray.addItem(realDataProvider.getItemAt(index));
								_isItemExist = false;
							}
						}
						else 
						{
							listItemArray.addItem(realDataProvider.getItemAt(index));
						}
					}
				}
				else
				{
					if (listItemArray)
					{
						listItemArray.removeAll();
						listItemArray.addItem(realDataProvider.getItemAt(index));
					}
				}
			}
			catch (e:Error)
			{
				trace ("EditListView : " + e.message)
			}
			
			listItemClickSignal.dispatch(listItemArray); 
		}
		
		private function searchForTheIndexFromDataProvider(o:Object):uint
		{
			var _index:uint = 0;
			var _length:uint = dataProvider.length;
			for (var i:int=0; i < _length; i++)
			{
				if (o == dataProvider.getItemAt(i))
				{
					_index = i;
					break;
				}
			}
			return _index
		}
		
		private function onRollOver(event:ListEvent):void
		{
			var _rowIndex:uint = uint(event.rowIndex);
			var _cel1:CellRenderer = dg.getCellRendererAt(_rowIndex, dg.getColumnIndex("影片名称")) as  CellRenderer;	
			var _cel2:CellRenderer = dg.getCellRendererAt(_rowIndex, dg.getColumnIndex("起始时间")) as  CellRenderer;
			var _cel3:CellRenderer = dg.getCellRendererAt(_rowIndex, dg.getColumnIndex("终止时间")) as  CellRenderer;
			_cel1.setStyle("upSkin", CellRenderer_overSkin);
			_cel2.setStyle("upSkin", CellRenderer_overSkin);
			_cel3.setStyle("upSkin", CellRenderer_overSkin);
		}
		
		private function onRollOut(event:ListEvent):void
		{
			var _rowIndex:uint = uint(event.rowIndex);
			var _cel1:CellRenderer = dg.getCellRendererAt(_rowIndex, dg.getColumnIndex("影片名称")) as  CellRenderer;	
			var _cel2:CellRenderer = dg.getCellRendererAt(_rowIndex, dg.getColumnIndex("起始时间")) as  CellRenderer;
			var _cel3:CellRenderer = dg.getCellRendererAt(_rowIndex, dg.getColumnIndex("终止时间")) as  CellRenderer;
			_cel1.setStyle("upSkin", CellRenderer_upSkin);
			_cel2.setStyle("upSkin", CellRenderer_upSkin);
			_cel3.setStyle("upSkin", CellRenderer_upSkin); 
		}
		
		public function fresh():void
		{
			dg.dataProvider = dataProvider;  
			dg.scrollToIndex(dg.dataProvider.length); 
		}
		
		public function scrollToSelected():void
		{
			dg.scrollToSelected();
		}
		
		public function get dataProvider():DataProvider
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:DataProvider):void
		{
			this._dataProvider = formatData(value);
		}
		
		private function formatData(dp:DataProvider):DataProvider
		{
			var items:DataProvider = new DataProvider();
			for (var i:int=0; i < dp.length; i++)
			{
				var item:Object = new Object();
				item.影片名称 = dp.getItemAt(i).影片名称;
				item.起始时间 = dp.getItemAt(i).起始时间;
				item.终止时间 = dp.getItemAt(i).终止时间;
				items.addItemAt(item,i);
			}
			
			for (var j:int=0; j < dp.length; j++)
			{
				items.getItemAt(j).起始时间 = TimeUtil.secondToTime(items.getItemAt(j).起始时间);
				items.getItemAt(j).终止时间 = TimeUtil.secondToTime(items.getItemAt(j).终止时间);  
			}
			return items;
		}
		
		public function get realDataProvider():DataProvider
		{
			return _realDataProvider;
		}
		
		public function set realDataProvider(value:DataProvider):void
		{
			_realDataProvider = value; 
		}
		
		public function clear():void
		{
			this.listItemArray = new DataProvider();
			this.dataProvider = new DataProvider();
			this.realDataProvider = new DataProvider();
			fresh();
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
