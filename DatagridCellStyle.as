package com.editor.style
{
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	
	import flash.text.*;
	
	public class DatagridCellStyle extends CellRenderer implements ICellRenderer
	{
		public function DatagridCellStyle()
		{
			super();
		}
		
		override protected function drawBackground():void
		{

			var format:TextFormat = new TextFormat(); 
			format.font = "微软雅黑";
			format.size = 12;
			format.color = 0x333333;      
			format.align = TextFormatAlign.CENTER;  
			setStyle("textFormat",format); 
			super.drawBackground();   
			
		}   
		
		override protected function drawLayout():void
		{
			this.textField.width = this.width;
			var format:TextFormat = new TextFormat();
			format.font = "微软雅黑";
			format.size = 12;
			format.color = 0x333333;
			format.align = TextFormatAlign.CENTER;
			this.textField.setTextFormat(format);
			super.drawLayout();
			
		}
	} 
}
