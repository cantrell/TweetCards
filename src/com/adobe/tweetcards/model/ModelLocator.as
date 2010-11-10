package com.adobe.tweetcards.model
{
	import com.adobe.tweetcards.events.CredentialsChangedEvent;
	import com.adobe.tweetcards.events.ScreenChangedEvent;
	import com.swfjunkie.tweetr.Tweetr;
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	public class ModelLocator extends EventDispatcher
	{

		private static var inst:ModelLocator;

		public var testMode:Boolean;
		public static const TEST_DATA_LENGTH:uint = 20;
		public static const APP_WIDTH:uint = 320;
		public static const APP_HEIGHT:uint = 460;
		public static const REPLY_MESSAGE_TYPE:uint = 0;
		public static const REPOST_MESSAGE_TYPE:uint = 1;
		public static const DIRECT_MESSAGE_TYPE:uint = 2;
		public static const PICTURE_SIZE:uint = 50;

		[Embed(source="/assets/background.png")]
		public var background:Class;

		[Embed(source="/assets/title_card.png")]
		public var titleCard:Class;

		[Embed(source="/assets/card_background.png")]
		public var cardBackground:Class;

		[Embed(source="/assets/sign_in_button.png")]
		public var signInButtonSkin:Class;

		[Embed(source="/assets/cancel_button.png")]
		public var cancelButtonSkin:Class;

		[Embed(source="/assets/tweet_button.png")]
		public var tweetButtonSkin:Class;

		[Embed(source="/assets/load_more_button.png")]
		public var loadMoreButtonSkin:Class;

		[Embed(source="/assets/menubar_short.png")]
		public var menuBarShortSkin:Class;

		[Embed(source="/assets/talk_bubble.png")]
		public var talkBubble:Class;

		private var so:SharedObject;
		private var _tweetr:Tweetr;
		private var _currentScreen:String;
		public var outgoingMessageData:Object;
		
		public function ModelLocator()
		{
			this.so = SharedObject.getLocal("tweetCards");
		}

		public function set credentials(credentials:Object):void
		{
			this.so.data["credentials"] = credentials;
			this.so.flush();
			var e:CredentialsChangedEvent = new CredentialsChangedEvent();
			this.dispatchEvent(e);
		}
		
		public function get credentials():Object
		{
			return this.so.data["credentials"];
		}
				
		public function set tweetr(tweetr:Tweetr):void
		{
			this._tweetr = tweetr;
		}
		
		public function get tweetr():Tweetr
		{
			return this._tweetr;
		}
		
		public function set currentScreen(screen:String):void
		{
			var oldScreen:String = this._currentScreen;
			this._currentScreen = screen;
			var e:ScreenChangedEvent = new ScreenChangedEvent();
			e.oldScreen = oldScreen;
			this.dispatchEvent(e);
		}
		
		public function get currentScreen():String
		{
			return this._currentScreen;
		}

		public static function getInstance():ModelLocator
		{
			if (inst == null)
			{
				inst = new ModelLocator();
			}
			return inst;
		}
	}
}