package com.editor.view.editlist
{
	import com.editor.controller.signals.*;
	import com.editor.controller.utils.Cookie;
	import com.editor.model.EditorModel;
	
	import fl.data.DataProvider;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditListMediator extends Mediator
	{
		[Inject]
		public var v:EditListView;
		
		[Inject]
		public var sendBeginTimeSignal:SendBeginTimeSignal;
		
		[Inject]
		public var sendEndTimeSignal:SendEndTimeSignal;
		
		[Inject]
		public var sendInsertSignal:SendInsertSignal;
		
		[Inject]
		public var sendDeleteSignal:SendDeleteSignal;
		
		[Inject]
		public var sendInsertSuccessSignal:SendInsertSuccessSignal;
		
		[Inject]
		public var sendDeleteSuccessSignal:SendDeleteSuccessSignal;
		
		[Inject]
		public var removeSelectedEffectSignal:RemoveSelectedEffectSignal;
		
		[Inject]
		public var showDataGridCurrentRowBackGroundColorSignal:ShowDataGridCurrentRowBackGroundColorSignal;
		
		[Inject]
		public var hideDataGridCurrentRowBackGroundColorSignal:HideDataGridCurrentRowBackGroundColorSignal;
		
		[Inject]
		public var deleteAllEditListDataSignal:DeleteAllEditListDataSignal;
		
		[Inject]
		public var setBeginTimeErrorSignal:SetBeginTimeErrorSignal;
		
		[Inject]
		public var setEndTimeErrorSignal:SetEndTimeErrorSignal;
		
		
		[Inject]
		public var m:EditorModel;
		
		public function EditListMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			v.listItemClickSignal.add(onListItemClick);
			sendBeginTimeSignal.add(onSendBeginTime);
			sendEndTimeSignal.add(onSendEndTime);
			sendInsertSignal.add(onInsertSignal);
			sendDeleteSignal.add(onDeleteSignal);
			showDataGridCurrentRowBackGroundColorSignal.add(onShowDataGridCurrentRowBackGroundColorSignal);
			hideDataGridCurrentRowBackGroundColorSignal.add(onHideDataGridCurrentRowBackGroundColorSignal);
			removeSelectedEffectSignal.add(onRemoveSelectedEffect); 
			deleteAllEditListDataSignal.add(onDeleteAllEditListDataSignal);
		}
		
		/**
		 *
		 * 清空编辑列表中数据，同时清空model中的数据 
		 * 
		 */		
		private function onDeleteAllEditListDataSignal():void
		{
			v.clear();
			m.destroy();
		}
		
		/**
		 * 
		 * 影片预览前移除所有选中效果
		 * 
		 */ 
		private function onRemoveSelectedEffect():void
		{
			m.currentSelectedItems = null; 
			v.listItemArray = new DataProvider();
			v.fresh();
		}
		
		/**
		 * 
		 * @param o : 需要操作行数据
		 * 显示当前行状态为鼠标滑过状态
		 * 
		 */		
		private function onShowDataGridCurrentRowBackGroundColorSignal(o:Object):void
		{
			v.showCurrentRowColor(o);
		}		
		
		private function onHideDataGridCurrentRowBackGroundColorSignal(o:Object):void
		{
			v.hideCurrentRowColor(o);
		}
		
		/**
		 *
		 * 判定当前行是否可插入数据 
		 * 
		 */		
		private function onInsertSignal():void
		{
			if (m.currentSelectedItems)
			{
				if (m.currentSelectedItems.length == 1 && m.dataprovider != null)
				{
					m.isInsert = true;
				}
			}
		}
		
		/**
		 *
		 * 删除数据操作 
		 * 
		 */		
		private function onDeleteSignal():void
		{
			/**
			 * dataprovider数据类型有别于其他数据类型，直接赋值操作，目标数据和源数据会同时改变
			 */ 
			if (m.dataprovider)
			{
				var len:int = m.dataprovider.length;
				var dp:DataProvider = new DataProvider();
				for (var index:int=0; index<len; index++)
				{
					dp.addItem(m.dataprovider.getItemAt(index));
				}
			} 
			
			if (m.currentSelectedItems)
			{
				try
				{
					if (m.currentSelectedItems.length >0 && m.dataprovider != null)
					{
						for (var i:int=0; i < m.dataprovider.length; i++)
						{
							for (var j:int=0; j<m.currentSelectedItems.length; j++)
							{
								if (m.dataprovider.getItemAt(i) == m.currentSelectedItems.getItemAt(j))
								{
									dp.removeItem(m.dataprovider.getItemAt(i)); 
									m.currentSelectedItems.removeItemAt(j);   			
									break;
								}
							}
							
							if(m.currentSelectedItems.length == 0)
							{
								trace ("onDeleteSignal: 所选数据已全部被删除");
								v.realDataProvider = dp; 
								v.dataProvider = dp;
								m.dataprovider = dp;
								v.fresh();
								sendDeleteSuccessSignal.dispatch("删除数据成功"); 
								m.currentSelectedItems = null;
								m.isInsert = false;
								
								setEndTimeRecord();
								if (m.dataprovider.length == 0)
								{
									m.endTimeRecord = 0;
								}
								return;
							}
						}
					}
				}
				catch (e:Error)
				{
					trace ("onDeleteSignal Error:" + e.message);
				}
			}
		}
		
		private function onListItemClick(listItemArray:DataProvider):void
		{
			m.currentSelectedItems = listItemArray;
		}
		
		/**
		 * 
		 * @param o : 起始时间对象
		 * 
		 */		
		private function onSendBeginTime(o:Object):void
		{
			if (m.isInsert){
				if (Number(m.currentSelectedItems.getItemAt(0).终止时间) < m.endTimeRecord){
					if (Number(o.起始时间) < Number(m.currentSelectedItems.getItemAt(0).终止时间) || Number(o.起始时间) > beginTimeOfTheNextItem){
						setBeginTimeErrorSignal.dispatch();
						return;
					}
				}else{
					if (Number(o.起始时间) < m.endTimeRecord){
						setBeginTimeErrorSignal.dispatch();
						return;
					}
				}
			}else{
				if (Number(o.起始时间) < m.endTimeRecord){
					setBeginTimeErrorSignal.dispatch();
					return;
				}
			}
			m.beginTime = o;
		}
		
		private function get beginTimeOfTheNextItem():Number
		{
			var suitableDataProvider:DataProvider = new DataProvider();
			var theNextBeginTime:Number = 0; 
			for (var index:int=0; index < m.dataprovider.length; index++)
			{
				if (Number(m.currentSelectedItems.getItemAt(0).终止时间) < Number(m.dataprovider.getItemAt(index).起始时间))
				{
					suitableDataProvider.addItem(m.dataprovider.getItemAt(index));
				}
			}
			
			theNextBeginTime = Number(suitableDataProvider.getItemAt(0).起始时间);
			for (var s:int=0; s<suitableDataProvider.length; s++)
			{
				if (Number(suitableDataProvider.getItemAt(s).起始时间) <= theNextBeginTime)
				{
					theNextBeginTime = Number(suitableDataProvider.getItemAt(s).起始时间);
				}
			}
			
			return theNextBeginTime;
		}
			
		/**
		 * 
		 * @param o ：选取的影片终止时间
		 * 插入所选取的片段数据到影片编辑列表
		 * 
		 */		
		private function onSendEndTime(o:Object):void
		{
			try
			{
				if (m.isInsert)
				{
					if (m.currentSelectedItems.getItemAt(0).终止时间 < m.endTimeRecord)
					{
						if (o.终止时间 > beginTimeOfTheNextItem)
						{
							setEndTimeErrorSignal.dispatch();
							return;
						}
					}
				}
				doInsert(o);
			}
			catch (e:Error)
			{
				trace ("EditListMediator : " + e.message);
			}
		}
		
		private function doInsert(o:Object):void
		{
			if (m.beginTime)
			{
				if (m.beginTime.影片名称 == o.影片名称)
				{
					if (Number(m.beginTime.起始时间) >= Number(o.终止时间) || Number(o.终止时间) - Number(m.beginTime.起始时间) < 1)
					{
						trace("Error:起始时间应不小于终止时间，且时间差应不小于1秒");
						return;
					}
					else
					{
						m.endTime = o;
						var dp:DataProvider = new DataProvider();
						if (m.dataprovider){
							dp = m.dataprovider;
						}
						var obj:Object = new Object();
						obj.影片名称 = m.beginTime.影片名称;
						obj.起始时间 = m.beginTime.起始时间;
						obj.终止时间 = o.终止时间;
						if (m.isInsert)
						{
							for (var i:int=0; i<m.dataprovider.length; i++)
							{
								if (m.currentSelectedItems.getItemAt(0) == m.dataprovider.getItemAt(i))
								{
									dp.addItemAt(obj,i+1);
									sendInsertSuccessSignal.dispatch("插入数据成功");
									break;
								}
							}
						}
						else
						{
							dp.addItem(obj);
						}
						m.dataprovider = dp;
						v.dataProvider = dp;
						v.realDataProvider = dp;
						v.fresh();
						recordEndTime();//记录后记录位置终止时
						
						m.beginTime = null;
						m.endTime = null;
						m.isInsert = false;
						m.currentSelectedItems = null;
					}
					
				}
				else
				{
					m.beginTime = null;
					m.endTime = null;
				}
			}
		}
		
		/**
		 * 
		 * @param items ：影片编辑列表中所以数据项集合
		 * 判定移除的数据项中是否有某路视频最后记录信息，存在则从最终观影记录中移除
		 * 
		 */		
		private function setEndTimeRecord():void
		{
			m.endTimeRecord = maxEndTime;
		}
		
		private function get maxEndTime():Number
		{
			var _maxEndTime:Number = 0;
			var _len:int = m.dataprovider.length;
			for (var i:int=0; i < _len; i++)
			{
				if (m.dataprovider.getItemAt(i).终止时间 >= _maxEndTime)
				{
					_maxEndTime = m.dataprovider.getItemAt(i).终止时间;
				}
			}
			return _maxEndTime;
		}
		
		/**
		 * 
		 * @param o ：影片截取数据项
		 * 记录该路视频最终观影记录为当前记录项
		 * 
		 */		
		private function recordEndTime():void
		{
			m.endTimeRecord = maxEndTime;
		}
		
		override public function onRemove():void
		{
			v.listItemClickSignal.remove(onListItemClick);
			sendBeginTimeSignal.remove(onSendBeginTime);
			sendEndTimeSignal.remove(onSendEndTime);
			sendInsertSignal.remove(onInsertSignal);
			sendDeleteSignal.remove(onDeleteSignal);
			showDataGridCurrentRowBackGroundColorSignal.remove(onShowDataGridCurrentRowBackGroundColorSignal);
			hideDataGridCurrentRowBackGroundColorSignal.remove(onHideDataGridCurrentRowBackGroundColorSignal);
			removeSelectedEffectSignal.remove(onRemoveSelectedEffect); 
			deleteAllEditListDataSignal.remove(onDeleteAllEditListDataSignal);
		}
	}
}
