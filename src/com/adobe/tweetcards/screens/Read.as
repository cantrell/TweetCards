﻿package com.adobe.tweetcards.screens
{
	import caurina.transitions.Tweener;
	
	import com.adobe.tweetcards.components.Card;
	import com.adobe.tweetcards.components.SimpleSkinnedButton;
	import com.adobe.tweetcards.events.CredentialsChangedEvent;
	import com.adobe.tweetcards.model.ModelLocator;
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.data.objects.DirectMessageData;
	import com.swfjunkie.tweetr.data.objects.StatusData;
	import com.swfjunkie.tweetr.data.objects.UserData;
	import com.swfjunkie.tweetr.events.TweetEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class Read extends Screen
	{
		public static const CARD_GAP:uint = 7;
		private var cardContainer:Sprite;
		private var currentCardIndex:uint;
		private var cardContainerX:int;
		private var cardX:uint;
		private var lastPage:uint;
		private var fingerTracker:int;
		private var moving:Boolean;
		private var loadMoreButton:SimpleSkinnedButton;
		
		public function Read()
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.draw();
		}

		protected override function draw():void
		{
			super.draw();
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.addEventListener(CredentialsChangedEvent.CREDENTIALS_CHANGED_EVENT, onCredentialsChanged);

			// Load more button
			this.loadMoreButton = new SimpleSkinnedButton(ml.loadMoreButtonSkin);
			this.loadMoreButton.visible = false;
			this.loadMoreButton.alpha = 0;
			this.centerHorizontally(this.loadMoreButton);
			this.loadMoreButton.y = 384;
			this.loadMoreButton.addEventListener(MouseEvent.CLICK, onGetMoreTweets);
			this.addChild(this.loadMoreButton);

			// Menubar
			var menuBarSkin:Bitmap = new ml.menuBarShortSkin();
			var bottomBar:Sprite = new Sprite();
			bottomBar.graphics.beginBitmapFill(menuBarSkin.bitmapData, null, false, false);
			bottomBar.graphics.drawRect(0, 0, 320, 31);
			bottomBar.graphics.endFill();
			bottomBar.x = 0;
			bottomBar.y = ModelLocator.APP_HEIGHT - 31;
			this.addChild(bottomBar);

			/*
			if (ml.credentials)
			{
				this.onCredentialsChanged(null);
			}
			*/
		}

		public override function onShow():void
		{
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		public override function onHide():void
		{
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onMouseDown(e:MouseEvent):void
		{
			if ((e.stageX < 105) && (e.stageY > ModelLocator.APP_HEIGHT - 41))
			{
				this.refresh();
				e.stopPropagation();
			}
			else if ((e.stageX > ModelLocator.APP_WIDTH - 105) && (e.stageY > ModelLocator.APP_HEIGHT - 41))
			{
				ModelLocator.getInstance().currentScreen = Screen.COMPOSE_SCREEN;
				e.stopPropagation();
			}
		}

		private function onCardMouseDown(e:MouseEvent):void
		{
			//if (this.moving) return;
			if (this.moving)
			{
				Tweener.removeAllTweens();
			}
			// TBD: Seems to be working yet
			//if (!e.isPrimaryTouchPoint) return;
			this.fingerTracker = e.stageX;
		}

		private function onCardMouseMove(e:MouseEvent):void
		{
			//if (!e.buttonDown || this.moving) return;
			if (!e.buttonDown) return;
			if (this.cardContainer != null)
			{
				var delta:int = e.stageX - this.fingerTracker;
				this.fingerTracker = e.stageX;
				this.cardContainer.x += delta;
			}
		}

		private function onCardMouseUp(e:MouseEvent):void
		{
			//if (this.moving) return;
			if ((this.cardContainerX - this.cardContainer.x) == 0)
			{
				// Let's remove tap scrolling support and see if the app behaves better.
				/*
				if (e.stageX <= (ModelLocator.APP_WIDTH / 2))
				{
					this.scrollBack();
				}
				else
				{
					this.scrollForward();
				}
				*/
			}
			else if (this.cardContainer.x > (CARD_GAP * 2)) // at the beginning
			{
				this.moving = true;
				Tweener.addTween(this.cardContainer, {x:(ModelLocator.APP_WIDTH - Card.WIDTH) / 2,time:.5, onComplete:onBackComplete});
			}
			else if ((this.cardContainer.x - (Card.WIDTH + (CARD_GAP * 3))) < (this.cardContainer.width * -1)) // at the end
			{
				this.moving = true;
				Tweener.addTween(this.cardContainer, {x:((this.cardContainer.width - (Card.WIDTH + (CARD_GAP * 3))) * -1),time:.5, onComplete:onForwardComplete});
			}
			else if ((this.cardContainerX - this.cardContainer.x) < 0)
			{
				this.scrollBack();
			}
			else
			{
				this.scrollForward();
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.RIGHT:
					this.scrollForward();
					break;
				case Keyboard.LEFT:
					this.scrollBack();
					break;
			}
		}

		private function initCardContainer():void
		{
			if (this.cardContainer != null)
			{
				this.removeChild(this.cardContainer);
				this.cardContainer = null;
			}
			this.currentCardIndex = 1;
			this.cardContainerX = (ModelLocator.APP_WIDTH - Card.WIDTH) / 2;
			this.cardContainer = new Sprite();
			this.cardContainer.x = this.cardContainerX;
			this.cardContainer.y = 55;

			this.cardContainer.addEventListener(MouseEvent.MOUSE_DOWN, onCardMouseDown);
			this.cardContainer.addEventListener(MouseEvent.MOUSE_MOVE, onCardMouseMove);
			this.cardContainer.addEventListener(MouseEvent.MOUSE_UP, onCardMouseUp);

			this.addChild(this.cardContainer);
			this.cardX = 0;
		}

		private function onIncomingTweets(e:TweetEvent):void
		{
			var tweets:Array = e.responseArray;
			if (tweets == null || tweets.length == 0) return;

			// Direct message response (after a DM was sent).
			// TBD: Do something better than nothing.
			if (tweets[0] is DirectMessageData)
			{
				return;
			}

			if (this.cardContainer == null)
			{
				this.initCardContainer();
			}

			for each (var tweet:StatusData in tweets)
			{
				var card:Card = new Card();
				card.x = this.cardX;
				card.setData(tweet.id,
							 tweet.createdAt,
							 tweet.text,
							 tweet.user.screenName,
							 tweet.user.id,
							 tweet.user.name,
							 tweet.user.profileImageUrl,
							 tweet.source,
							 tweet.user.location,
							 tweet.user.followersCount);
				this.cardContainer.addChild(card);
				card.cacheAsBitmap = true;
				this.cardX += (Card.WIDTH + CARD_GAP);
			}

			// Decide whether or not to automatically scroll forward.
			// We should only scroll forward if we're adding additional pages.
			if (this.currentCardIndex != 1)
			{
				this.scrollForward();
			}
		}

		private function onTwitterFail(e:TweetEvent):void
		{
			trace("Twitter failure.", e.info);
		}
				
		private function scrollForward():void
		{
			if (this.currentCardIndex == this.cardContainer.numChildren) return;
			this.moving = true;
			this.hideLoadMoreButton();
			++this.currentCardIndex;
			this.cardContainerX -= (Card.WIDTH + CARD_GAP);
			Tweener.addTween(this.cardContainer, {x:this.cardContainerX, time:1, onComplete:onForwardComplete});
		}
				
		private function onForwardComplete():void
		{
			this.moving = false;
			if (this.currentCardIndex == this.cardContainer.numChildren)
			{
				this.showLoadMoreButton();
			}
		}
		
		private function showLoadMoreButton():void
		{
			this.loadMoreButton.alpha = 0;
			this.loadMoreButton.visible = true;
			Tweener.addTween(this.loadMoreButton, {alpha:1,time:1});
		}
		
		private function hideLoadMoreButton():void
		{
			if (this.loadMoreButton.visible)
			{
				this.loadMoreButton.visible = false;
				this.loadMoreButton.alpha = 0;
			}
		}
		
		private function scrollBack():void
		{
			if (this.currentCardIndex == 1) return;
			this.moving = true;
			this.hideLoadMoreButton();
			--this.currentCardIndex;
			this.cardContainerX += (Card.WIDTH + CARD_GAP);
			Tweener.addTween(this.cardContainer, {x:this.cardContainerX, time:1, onComplete:onBackComplete});
		}

		private function onBackComplete():void
		{
			this.moving = false;
		}

		private function onGetMoreTweets(e:MouseEvent):void
		{
			this.hideLoadMoreButton();
			this.getTweets();
		}
		
		private function createTestData():void
		{
			var e:TweetEvent = new TweetEvent(TweetEvent.COMPLETE);
			var responseArray:Array = new Array();
			var user:UserData = new UserData();
			user.id = 111;
			user.followersCount = 222;
			user.location = "Washington DC";
			user.profileImageUrl = "http://s3.amazonaws.com/twitter_production/profile_images/246797407/cantrell_100x100_bigger.jpg";
			user.name = "Christian Cantrell";
			user.screenName = "cantrell";
			user.url = "http://www.livingdigitally.net";
			for (var i:uint = 0; i < ModelLocator.TEST_DATA_LENGTH; ++i)
			{
				var data:StatusData = new StatusData();
				data.user = user;
				data.createdAt = "Fri May 29 21:19:22 +0000 2009";
				data.id = 333;
				data.source = '<a href="http://brightkite.com">Brightkite</a>';
				data.text = "This is a tweet with &lt;HTML&gt; entities and a URL: http://twitpic.com/eddz0 It should fit properly within the card and be rendered right.";
				responseArray.push(data);
			}
			e.responseArray = responseArray;
			this.onIncomingTweets(e);
		}
		
		private function onCredentialsChanged(e:CredentialsChangedEvent = null):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			if (ml.credentials)
			{
				var tweetr:Tweetr = new Tweetr(ml.credentials.username, ml.credentials.password);
				tweetr.browserAuth = false;
				ml.tweetr = tweetr;
				ml.tweetr.addEventListener(TweetEvent.COMPLETE, onIncomingTweets);
				ml.tweetr.addEventListener(TweetEvent.FAILED, onTwitterFail);
				this.lastPage = 1;
				this.getTweets();
			}
		}
		
		private function getTweets():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			if (ml.testMode)
			{
				this.createTestData();
			}
			else
			{
				ml.tweetr.getFriendsTimeLine(null, null, 0, this.lastPage++);
			}
		}
		
		private function refresh():void
		{
			this.initCardContainer();
			this.getTweets();
		}
	}
}