package com.editor.style
{
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	
	import flash.display.DisplayObject;
	import flash.text.*;
	
	public class DatagridNameCellStyle extends CellRenderer implements ICellRenderer
	{
		public function DatagridNameCellStyle()
		{
			super();
		}
		
		override protected function drawBackground():void
		{
			var format:TextFormat = new TextFormat(); 
			format.font = "微软雅黑";
			format.size = 12;
			//format.bold = true;
			//format.color = Math.random() * 0xFFFFFF;   
			format.color = 0x777777;
			format.align = TextFormatAlign.CENTER; 
			setStyle("textFormat",format); 
			//setStyle("upSkin", CellRenderer_upSkin_grey);
			super.drawBackground();    
			
		}   
		
		override protected function drawLayout():void
		{
			this.textField.width = this.width;
			var format:TextFormat = new TextFormat();
			format.font = "微软雅黑";
			format.size = 12;
			//format.bold = true;
			//format.color = Math.random() * 0xFFFFFF;
			format.color = 0x777777;
			format.align = TextFormatAlign.CENTER;
			this.textField.setTextFormat(format);
			//setStyle("upSkin", CellRenderer_upSkin_grey); //单独设置upSkin
			super.drawLayout();
		}
	}
}
