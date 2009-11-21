package com.adobe.tweetcards.components
{
	import com.adobe.tweetcards.model.ModelLocator;
	import com.adobe.tweetcards.screens.Screen;
	import com.adobe.tweetcards.util.ImageCache;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	public class Card extends Sprite
	{
		
		public static const WIDTH:uint = 282;
		public static const HEIGHT:uint = 317;
		
		//private var shadow:DropShadowFilter;
		private static var HTML_RE:RegExp = /<(.|\n)*?>/g;
		private static var URL_RE:RegExp = /(http(s?)|feed|ftp):\/\/.[^ ]+/;
		private static var ENTITY_RE:RegExp = /&.+;/;
		
		private var _id:Number;
		private var _createdAt:String;
		private var _text:String;
		private var _username:String;
		private var _userId:int;
		private var _fullName:String;
		private var _userImageUrl:String;
		private var _twitterClient:String;
		private var _followers:uint;
		private var _location:String;
		
		public function Card()
		{
			super();

			//this.shadow = new DropShadowFilter(1);

			// background
			var ml:ModelLocator = ModelLocator.getInstance();
			var cardBackground:Bitmap = new ml.cardBackground();
			this.graphics.beginBitmapFill(cardBackground.bitmapData, null, false, false);
			this.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			this.graphics.endFill();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onClick);
			this.addEventListener(MouseEvent.MOUSE_UP, onClick);
		}
		
		public function setData(id:Number,
								createdAt:String,
								text:String,
								username:String,
								userId:int,
								fullName:String,
								userImageUrl:String,
								twitterClient:String,
								location:String,
								followers:uint):void
		{
			this._id = id;
			this._createdAt = createdAt;
			this._text = text;
			this._username = username;
			this._userId = userId;
			this._fullName = fullName;
			this._userImageUrl = userImageUrl;
			this._twitterClient = twitterClient.replace(Card.HTML_RE, "");
			this._location = location;
			this._followers = followers;
			
			// image
			var imageCache:ImageCache = ImageCache.getInstance();
			var imageBitmap:Bitmap = imageCache.getImage(userImageUrl);
			if (imageBitmap == null)
			{
				this.downloadImage(userImageUrl);
			}
			else
			{
				addImage(imageBitmap);
			}
			
			// username
			var usernameLabel:SimpleLabel = new SimpleLabel("@"+username, "bold", 0x000000, "_sans", 15);
			usernameLabel.x = 81;
			usernameLabel.y = 21;
			this.addChild(usernameLabel);

			var fullNameLabel:SimpleLabel = new SimpleLabel(fullName, "normal", 0x000000, "_sans", 13);
			fullNameLabel.x = 81;
			fullNameLabel.y = usernameLabel.y + 20;
			this.addChild(fullNameLabel);
			
			// tweet
			var tweetText:SimpleMultiLineTextField = new SimpleMultiLineTextField(250, 150, this.sanitize(this._text), "normal", 0x212121);
			tweetText.x = 25;
			tweetText.y = 88;
			this.addChild(tweetText);

			// time and client info
			var postedOnDate:Date = new Date(createdAt);
			var postedOnDateString:String = this.formatDate(postedOnDate);
			var metaString:String = "Posted " + postedOnDateString + " from " + this._twitterClient;
			var metaLabel:SimpleLabel = new SimpleLabel(metaString, "normal", 0x858585, "_sans", 10);
			metaLabel.x = 27;
			metaLabel.y = tweetText.y + tweetText.textField.textHeight + 18;
			this.addChild(metaLabel);			
		}
		
		public function get id():Number
		{
			return this._id;
		}
		
		private function onClick(e:MouseEvent):void
		{
			if (e.localY > Card.HEIGHT - 55)
			{
				e.stopImmediatePropagation();
				if (e.type != MouseEvent.MOUSE_UP) return;
				if (e.localX < Card.WIDTH / 3)
				{
					this.onReply();
				}
				else if (e.localX > (Card.WIDTH - (Card.WIDTH / 3)))
				{
					this.onDirectMessage();
				}
				else
				{
					this.onRepost();
				}
			}
		}
		
		private function sanitize(text:String):String
		{
			var formattedText:String = new String();
			formattedText = text.replace(Card.URL_RE, '<font color="#0000ff"><a href="$&">$&</a></font>');
			return formattedText;
		}
		
		private function onReply():void
		{
			var messageData:Object = new Object();
			messageData.type = ModelLocator.REPLY_MESSAGE_TYPE;
			messageData.prefix = "@"+this._username + " ";
			messageData.tweetId = this._id;
			messageData.userId = this._userId;
			messageData.username = this._username;
			messageData.fullName = this._fullName;
			ModelLocator.getInstance().outgoingMessageData = messageData;
			ModelLocator.getInstance().currentScreen = Screen.COMPOSE_SCREEN;
		}

		private function onRepost():void
		{
			var messageData:Object = new Object();
			messageData.type = ModelLocator.REPOST_MESSAGE_TYPE;
			messageData.prefix = "RT " + (this._text) + " (via @" + this._username + ")";
			messageData.userId = this._userId;
			messageData.username = this._username;
			messageData.fullName = this._fullName;
			ModelLocator.getInstance().outgoingMessageData = messageData;
			ModelLocator.getInstance().currentScreen = Screen.COMPOSE_SCREEN;
		}

		private function onDirectMessage():void
		{
			var messageData:Object = new Object();
			messageData.type = ModelLocator.DIRECT_MESSAGE_TYPE;
			messageData.prefix = "";
			messageData.userId = this._userId;
			messageData.username = this._username;
			messageData.fullName = this._fullName;
			ModelLocator.getInstance().outgoingMessageData = messageData;
			ModelLocator.getInstance().currentScreen = Screen.COMPOSE_SCREEN;
		}
		
		private function formatDate(d:Date):String
		{
			var now:Date = new Date();
			var diff:Number = (now.time - d.time) / 1000; // convert to seconds
			if (diff < 60) // just posted
			{
				return "under a minute ago";
			}
			else if (diff < 3600) // n minutes ago
			{
				var minutes:uint = Math.round(diff / 60);
				return minutes + ((minutes == 1) ? " minute ago" : " minutes ago");
			}
			else if (diff < 86400) // n hours ago
			{
				var hours:uint = Math.round(diff / 3600);
				return hours + ((hours == 1) ? " hour ago" : " hours ago");
			}
			else // n days ago
			{
				var days:uint = Math.round(diff / 86400);
				return days + ((days == 1) ? " day ago" : " days ago");
			}
		}
		
		private function downloadImage(userImageUrl:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			var req:URLRequest = new URLRequest(userImageUrl);
			loader.load(req);
		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			trace("IOError:", e.text);
		}
				
		private function addImage(imageBitmap:Bitmap):void
		{
			if (imageBitmap == null) return;
			imageBitmap.smoothing = true;
			if (imageBitmap.width > ModelLocator.PICTURE_SIZE)
			{
				var xFactor:Number = ModelLocator.PICTURE_SIZE / imageBitmap.width;
				imageBitmap.scaleX = xFactor;
				imageBitmap.scaleY = xFactor;
			}
			imageBitmap.x = 10;
			imageBitmap.y = 10;
			/*
			var mask:Sprite = new Sprite();
			mask.x = 10;
			mask.y = 10;
			mask.graphics.beginFill(0xffffff);
			mask.graphics.drawRoundRect(0, 0, imageBitmap.width, imageBitmap.height, 10);
			mask.graphics.endFill();
			this.addChild(mask);
			imageBitmap.mask = mask;
			*/
			//imageBitmap.filters = [this.shadow];
			this.addChild(imageBitmap);
		}
		
		private function onImageLoaded(e:Event):void
		{
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			try
			{
				var bitmap:Bitmap = Bitmap(loader.content);
			}
			catch (e:TypeError)
			{
				trace("URL didn't point to an image.");
				return;
			}
			var url:String = loaderInfo.url;
			var imageCache:ImageCache = ImageCache.getInstance();
			imageCache.addImage(url, bitmap);
			this.addImage(bitmap);
		}
	}
}