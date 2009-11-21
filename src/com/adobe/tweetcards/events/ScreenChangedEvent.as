package com.adobe.tweetcards.events
{
	import flash.events.Event;

	public class ScreenChangedEvent extends Event
	{
		public static var SCREEN_CHANGED_EVENT:String = "screenChangedEvent";
		public var oldScreen:String;
		
		public function ScreenChangedEvent()
		{
			super(SCREEN_CHANGED_EVENT);
		}
		
	}
}