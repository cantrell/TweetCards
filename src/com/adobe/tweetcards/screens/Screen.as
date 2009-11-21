package com.adobe.tweetcards.screens
{
	import com.adobe.tweetcards.model.ModelLocator;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class Screen extends Sprite
	{
		
		public static const ACCOUNT_SCREEN:String = "accountScreen";
		public static const COMPOSE_SCREEN:String = "composeScreen";
		public static const READ_SCREEN:String  = "readScreen";
		
		public function Screen()
		{
			super();
		}

		protected function draw():void
		{
		}
		
		protected function centerHorizontally(displayObj:DisplayObject):void
		{
			displayObj.x = (ModelLocator.APP_WIDTH / 2) - (displayObj.width / 2);
		}

		protected function centerVertically(displayObj:DisplayObject):void
		{
			displayObj.y = (ModelLocator.APP_HEIGHT / 2) - (displayObj.height / 2);
		}
		
		public function onShow():void
		{
		}

		public function onHide():void
		{
		}
	}
}