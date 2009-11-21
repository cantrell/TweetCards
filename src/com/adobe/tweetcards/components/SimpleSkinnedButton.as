package com.adobe.tweetcards.components
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class SimpleSkinnedButton extends Sprite
	{
		//private var glow:GlowFilter;
		
		public function SimpleSkinnedButton(bitmapClass:Class)
		{
			super();

			//this.glow = new GlowFilter();
			var bm:Bitmap = new bitmapClass();
			this.graphics.beginBitmapFill(bm.bitmapData, null, false, false);
			graphics.drawRoundRect(0, 0, bm.bitmapData.width, bm.bitmapData.height, 5, 5);
			graphics.endFill();
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