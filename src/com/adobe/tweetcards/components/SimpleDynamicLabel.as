package com.adobe.tweetcards.components
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;

	public class SimpleDynamicLabel extends Sprite
	{
		public var textField:TextField;
		private var glow:GlowFilter;
		
		public function SimpleDynamicLabel(initialText:String,
										   fontWeight:String = "normal",
										   color:int = 0xffffff,
										   font:String = "_sans",
										   size:uint = 18)
		{
			super();
			
			this.glow = new GlowFilter(0xff0000);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = color;
			textFormat.font = font;
			textFormat.size = size;
			textFormat.bold = (fontWeight == "normal") ? false : true;

			this.textField = new TextField();
			this.textField.defaultTextFormat = textFormat;
			this.textField.selectable = false;
			this.textField.antiAliasType = AntiAliasType.ADVANCED;
			this.textField.text = initialText;
			this.addChild(this.textField);
		}
		
		public function get value():String
		{
			return this.textField.text;
		}

		public function update(newText:String):void
		{
			this.textField.text = newText;
		}
		
		public function addGlow():void
		{
			this.textField.filters = [this.glow];
		}

		public function removeGlow():void
		{
			this.textField.filters = null;
		}
	}
}