package com.adobe.tweetcards.components
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class SimpleMultiLineTextField extends Sprite
	{
		public var textField:TextField;
				
		public function SimpleMultiLineTextField(width:uint,
												 height:uint,
												 text:String,
												 fontWeight:String = "normal",
												 fontColor:int = 0x000000,
												 fontName:String = "_sans",
												 fontSize:uint = 18)
		{
			super();

			var textFormat:TextFormat = new TextFormat();
			textFormat.color = fontColor;
			textFormat.font = fontName;
			textFormat.size = fontSize;
			textFormat.bold = (fontWeight == "normal") ? false : true;

			this.textField = new TextField();
			textField.width = width;
			textField.height = height;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.selectable = false;
			textField.defaultTextFormat = textFormat;
			textField.htmlText = text;
			textField.x = 0;
			textField.y = 0;
			// TBD: This houldn't have to be here. Remove when text performance bug is fixed.
			textField.cacheAsBitmap = true;
			this.addChild(textField);
		}
	}
}