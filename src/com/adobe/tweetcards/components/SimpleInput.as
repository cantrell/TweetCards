package com.adobe.tweetcards.components
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class SimpleInput extends Sprite
	{
		public var textField:TextField;
		
		public function SimpleInput(width:uint,
									height:uint,
									multiline:Boolean = false,
									password:Boolean = false,
									color:int = 0x484848,
									font:String = "_sans",
									size:uint = 18)
		{
			super();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = color;
			textFormat.font = font;
			textFormat.size = size;

			this.textField = new TextField();
			this.textField.antiAliasType = AntiAliasType.ADVANCED;
			this.textField.type = TextFieldType.INPUT;
			this.textField.displayAsPassword = password;
			this.textField.border = true;
			this.textField.borderColor = color;
			this.textField.background = true;
			this.textField.backgroundColor = 0xececec;
			this.textField.multiline = multiline;
			if (multiline)
			{
				this.textField.wordWrap = true;
			}
			this.textField.width = width;
			this.textField.height = height;
			this.textField.defaultTextFormat = textFormat;
			this.addChild(this.textField);
		}
		
		public function get value():String
		{
			return this.textField.text;
		}
	}
}