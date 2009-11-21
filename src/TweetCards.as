package
{
	import caurina.transitions.Tweener;
	
	import com.adobe.tweetcards.components.SimpleButton;
	import com.adobe.tweetcards.events.ScreenChangedEvent;
	import com.adobe.tweetcards.model.ModelLocator;
	import com.adobe.tweetcards.screens.Account;
	import com.adobe.tweetcards.screens.Compose;
	import com.adobe.tweetcards.screens.Read;
	import com.adobe.tweetcards.screens.Screen;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	[SWF(frameRate=24)]
	public class TweetCards extends Sprite
	{
		private var model:ModelLocator;
		
		//private var intro:Intro;
		private var read:Read;
		private var compose:Compose;
		private var account:Account;
		
		private var screenScroller:Sprite;
		
		private var currentView:Screen;
		
		private var readButton:SimpleButton;
		private var postButton:SimpleButton;
		private var accountButton:SimpleButton;
		
		public function TweetCards()
		{
			super();
			this.stage.quality = StageQuality.BEST;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.model = ModelLocator.getInstance();
			this.init();
		}
		
		private function init():void
		{
			// Create the global background
			var bg:Bitmap = new model.background();
			this.graphics.beginBitmapFill(bg.bitmapData, null, false, false);
			this.graphics.drawRect(0, 0, ModelLocator.APP_WIDTH, ModelLocator.APP_HEIGHT);
			this.graphics.endFill();

			this.screenScroller = new Sprite();

			this.account = new Account();
			this.account.cacheAsBitmap = true;
			this.account.x = 0;
			this.account.y = 0;
			this.screenScroller.addChild(this.account);

			this.read = new Read();
			this.read.x = 0;
			this.read.y = this.account.y + ModelLocator.APP_HEIGHT;
			this.screenScroller.addChild(read);

			this.compose = new Compose();
			this.compose.cacheAsBitmap = true;
			this.compose.x = 0;
			this.compose.y = this.read.y + ModelLocator.APP_HEIGHT;
			this.screenScroller.addChild(this.compose);
			
			this.stage.addChild(this.screenScroller);
			
			this.model.addEventListener(ScreenChangedEvent.SCREEN_CHANGED_EVENT, onNavChange);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			switch (e.keyCode)
			{
				case Keyboard.DOWN:
					if (this.currentView == this.account)
					{
						ml.currentScreen = Screen.READ_SCREEN;
					}
					else if (this.currentView == this.read)
					{
						ml.currentScreen = Screen.COMPOSE_SCREEN;
					}
					else if (this.currentView == this.compose)
					{
						ml.currentScreen = Screen.ACCOUNT_SCREEN;
					}
					break;
				case Keyboard.UP:
					if (this.currentView == this.compose)
					{
						ml.currentScreen = Screen.READ_SCREEN;
					}
					else if (this.currentView == this.account)
					{
						ml.currentScreen = Screen.COMPOSE_SCREEN;
					}
					else if (this.currentView == this.read)
					{
						ml.currentScreen = Screen.ACCOUNT_SCREEN;
					}
					break;
			}
		}
		
		private function start(e:Event):void
		{
			this.accountButton.removeEventListener(Event.ADDED_TO_STAGE, start);
			this.model.currentScreen = Screen.ACCOUNT_SCREEN;
		}
		
		private function onNavButtonClick(e:MouseEvent):void
		{
			var target:SimpleButton = e.currentTarget as SimpleButton;

			if (target == this.readButton)
			{
				this.model.currentScreen = Screen.READ_SCREEN;
			}
			else if (target == this.postButton)
			{
				this.model.currentScreen = Screen.COMPOSE_SCREEN;
			}
			else if (target == this.accountButton)
			{
				this.model.currentScreen = Screen.ACCOUNT_SCREEN;
			}
		}

		private function onNavChange(e:ScreenChangedEvent):void
		{
			if (e.oldScreen == Screen.ACCOUNT_SCREEN)
			{
				//this.accountButton.removeGlow();
				this.account.onHide();
			}
			else if (e.oldScreen == Screen.COMPOSE_SCREEN)
			{
				//this.postButton.removeGlow();
				this.compose.onHide();
			}
			else if (e.oldScreen == Screen.READ_SCREEN)
			{
				//this.readButton.removeGlow();
				this.read.onHide();
			}

			var targetTween:Screen;

			if (this.model.currentScreen == Screen.READ_SCREEN)
			{
				targetTween = this.read;
				//this.readButton.addGlow();
			}
			else if (this.model.currentScreen == Screen.COMPOSE_SCREEN)
			{
				targetTween = this.compose;
				//this.postButton.addGlow();
			}
			else if (this.model.currentScreen == Screen.ACCOUNT_SCREEN)
			{
				targetTween = this.account;
				//this.accountButton.addGlow();
			}
			
			Tweener.addTween(this.screenScroller, {y:targetTween.y * -1,time:1});
			targetTween.onShow();
			this.currentView = targetTween;
		}
	}
}