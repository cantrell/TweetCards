package com.adobe.tweetcards.util
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class ImageCache
	{
		private static var inst:ImageCache;
		private var cache:Object;
		
		public function ImageCache()
		{
			this.cache = new Object();
		}

		public function addImage(key:String, image:Bitmap):void
		{
			if (this.cache[key] == null)
			{
				var val:Object = new Object();
				val.image = image;
				val.time = new Date().time;
				this.cache[key] = val;
			}
			else
			{
				this.cache[key].time = new Date().time;
			}
		}

		public function removeImage(key:String):void
		{
			delete this.cache[key];
		}
		
		public function getImage(key:String):Bitmap
		{
			var val:Object = this.cache[key];
			if (!val) return null;
			var bitmap:Bitmap = val.image as Bitmap;
			var bitmapData:BitmapData = bitmap.bitmapData;
			var newBitmapData:BitmapData = bitmapData.clone();
			return new Bitmap(newBitmapData);
		}

		public static function getInstance():ImageCache
		{
			if (inst == null)
			{
				inst = new ImageCache();
			}
			return inst;
		}
	}
}