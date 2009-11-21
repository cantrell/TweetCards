package com.adobe.tweetcards.components
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	//import flash.filters.BevelFilter;
	//import flash.filters.BitmapFilterType;
	//import flash.filters.DropShadowFilter;
	//import flash.filters.GlowFilter;
	
	
	public class SimpleButton extends Sprite
	{
		//private var glow:GlowFilter;
		//private var bevel:BevelFilter;
		//private var labelShadow:DropShadowFilter;
		
		public function SimpleButton(label:String, forcedWidth:int = -1, forcedHeight:int = -1)
		{
			super();

			//this.glow = new GlowFilter();
			//this.bevel = new BevelFilter();
			//bevel.distance = 1;
			//bevel.strength = 1;
			//this.filters = [bevel];
			//this.labelShadow = new DropShadowFilter();
			//this.labelShadow.distance = .5;
			//this.labelShadow.angle = 0;
			//this.labelShadow.color = 0x212121;

			var buttonLabel:SimpleLabel = new SimpleLabel(label);
			//buttonLabel.filters = [this.labelShadow];

			var buttonWidth:uint = (forcedWidth == -1) ? buttonLabel.textWidth + 6 : forcedWidth;
			var buttonHeight:uint = (forcedHeight == -1) ? buttonLabel.textHeight + 6 : forcedHeight;

			this.graphics.beginGradientFill(GradientType.LINEAR, [0x333333, 0x030608], [1,1], [0,255]);
			graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 5, 5);
			graphics.endFill();

			buttonLabel.x = (buttonWidth / 2) - (buttonLabel.textWidth / 2);
			buttonLabel.y = ((buttonHeight / 2) + (buttonLabel.textHeight / 2)) - 3;
			this.addChild(buttonLabel);
		}
		
		public function addGlow():void
		{
			//this.filters = [this.glow, this.bevel];
		}

		public function removeGlow():void
		{
			//this.filters = [this.bevel];
		}
	}
}