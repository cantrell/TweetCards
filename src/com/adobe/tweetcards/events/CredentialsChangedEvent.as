package com.adobe.tweetcards.events
{
	import flash.events.Event;

	public class CredentialsChangedEvent extends Event
	{
		public static var CREDENTIALS_CHANGED_EVENT:String = "credentialsChangedEvent";
		
		public function CredentialsChangedEvent()
		{
			super(CREDENTIALS_CHANGED_EVENT);
		}
		
	}
}