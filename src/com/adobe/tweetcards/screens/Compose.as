package com.adobe.tweetcards.screens
{
	import com.adobe.tweetcards.components.SimpleDynamicLabel;
	import com.adobe.tweetcards.components.SimpleInput;
	import com.adobe.tweetcards.components.SimpleLabel;
	import com.adobe.tweetcards.components.SimpleSkinnedButton;
	import com.adobe.tweetcards.events.CredentialsChangedEvent;
	import com.adobe.tweetcards.model.ModelLocator;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	
	public class Compose extends Screen
	{
		
		private var input:SimpleInput;
		private var countdown:SimpleDynamicLabel;
		private var glow:GlowFilter;
		//private var shadow:DropShadowFilter;
		private var instructions:SimpleLabel;
		private var talkBubble:Sprite;
		
		public function Compose()
		{
			super();
			this.glow = new GlowFilter(0xff0000);
			//this.shadow = new DropShadowFilter(1);
			this.draw();
		}

		protected override function draw():void
		{
			super.draw();
			
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.addEventListener(CredentialsChangedEvent.CREDENTIALS_CHANGED_EVENT, onCredentialsChanged);
			
			var bubbleBitmap:Bitmap = new ml.talkBubble();
			this.talkBubble = new Sprite();
			this.talkBubble.graphics.beginBitmapFill(bubbleBitmap.bitmapData, null, false, false);
			this.talkBubble.graphics.drawRect(0, 0, 245, 194);
			this.talkBubble.graphics.endFill();
			this.talkBubble.x = 67;
			this.talkBubble.y = 8;
			this.addChild(this.talkBubble);
			
			this.input = new SimpleInput(220, 150, true);
			input.textField.border = false;
			input.textField.background = false;
			input.x = 20;
			input.y = 10;
			this.input.textField.addEventListener(Event.CHANGE, onTextChange);
			this.talkBubble.addChild(input);

			this.countdown = new SimpleDynamicLabel("140", "bold", 0xd2d2d2, "Helvetica", 30);
			this.countdown.x = 141;
			this.countdown.y = 161;
			this.countdown.textField.autoSize = TextFieldAutoSize.RIGHT;
			this.talkBubble.addChild(this.countdown);

			// Cancel button
			var cancelButton:SimpleSkinnedButton = new SimpleSkinnedButton(ml.cancelButtonSkin);
			cancelButton.x = 80;
			cancelButton.y = 210;
			cancelButton.addEventListener(MouseEvent.CLICK, onCancel);
			this.addChild(cancelButton);

			// Tweet button
			var tweetButton:SimpleSkinnedButton = new SimpleSkinnedButton(ml.tweetButtonSkin);
			tweetButton.x = cancelButton.x + 119;
			tweetButton.y = 210;
			tweetButton.addEventListener(MouseEvent.CLICK, onPost);
			this.addChild(tweetButton);
		}
		
		private function onCredentialsChanged(e:CredentialsChangedEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			if (ml.credentials == null) return;
			if (ml.testMode)
			{
				this.loadImage("http://s3.amazonaws.com/twitter_production/profile_images/246797407/cantrell_100x100_bigger.jpg");
			}
			else
			{
				var req:URLRequest = new URLRequest("http://twitter.com/users/show.xml?screen_name=" + ml.credentials.username);
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onUserDataComplete);
				urlLoader.load(req);
			}
		}
		
		private function onUserDataComplete(e:Event):void
		{
			var urlLoader:URLLoader = e.target as URLLoader;
			var responseXml:XML = XML(urlLoader.data);
			var profileImageUrl:String = responseXml.profile_image_url;
			this.loadImage(profileImageUrl);
		}
		
		private function loadImage(imageUrl:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			var req:URLRequest = new URLRequest(imageUrl);
			loader.load(req);
		}
		
		private function onImageLoaded(e:Event):void
		{
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var imageBitmap:Bitmap;
			try
			{
				imageBitmap = Bitmap(loader.content);
			}
			catch (e:TypeError)
			{
				trace("URL didn't point to an image.");
				return;
			}

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
		
		private function onTextChange(e:Event = null):void
		{
			this.countdown.update(String(140 - this.input.value.length));
			if (int(this.countdown.value) < 0)
			{
				this.countdown.addGlow();
			}
			else
			{
				this.countdown.removeGlow();
			}
		}
		
		public override function onShow():void
		{
			var outgoingMessageData:Object = ModelLocator.getInstance().outgoingMessageData;
			if (outgoingMessageData != null)
			{
				this.input.textField.htmlText = outgoingMessageData.prefix;
				this.onTextChange(null);
				var instructionString:String;
				if (outgoingMessageData.type == ModelLocator.REPLY_MESSAGE_TYPE)
				{
					instructionString = "Replying...";
				}
				else if (outgoingMessageData.type == ModelLocator.REPOST_MESSAGE_TYPE)
				{
					instructionString = "Reposting...";
				}
				else if(outgoingMessageData.type == ModelLocator.DIRECT_MESSAGE_TYPE)
				{
					instructionString = "DM to @" + outgoingMessageData.username;
				}
				this.instructions = new SimpleLabel(instructionString, "normal", 0xd2d2d2, "Helvetica", 14);
				this.instructions.x = 18;
				this.instructions.y = 187;
				this.talkBubble.addChild(this.instructions);
			}
			this.stage.focus = this.input.textField;
			this.input.textField.setSelection(this.input.textField.length, this.input.textField.length);
		}
		
		public override function onHide():void
		{
			this.input.textField.text = "";
			this.onTextChange(null);
			if (this.instructions && this.talkBubble.contains(this.instructions))
			{
				this.talkBubble.removeChild(this.instructions);
			}
			ModelLocator.getInstance().outgoingMessageData = null;
		}
		
		private function onCancel(e:MouseEvent):void
		{
			this.onHide();
			ModelLocator.getInstance().currentScreen = Screen.READ_SCREEN;
		}
		
		private function onPost(e:MouseEvent):void
		{
			if (this.input.value.length == 0 || this.input.value.length > 140) return;
			var ml:ModelLocator = ModelLocator.getInstance();
			var outgoingMessageData:Object = ml.outgoingMessageData;
			if (outgoingMessageData != null)
			{
				if (outgoingMessageData.type == ModelLocator.REPLY_MESSAGE_TYPE)
				{
					if (ml.testMode)
					{
						trace("Replying...", outgoingMessageData.tweetId, this.input.value);
					}
					else
					{
						ml.tweetr.sendTweet(this.input.value, outgoingMessageData.tweetId);
					}
				}
				else if (outgoingMessageData.type == ModelLocator.REPOST_MESSAGE_TYPE)
				{
					if (ml.testMode)
					{
						trace("Reposting...", this.input.value);
					}
					else
					{
						ml.tweetr.sendTweet(this.input.value);
					}
				}
				else if (outgoingMessageData.type == ModelLocator.DIRECT_MESSAGE_TYPE)
				{
					if (ml.testMode)
					{
						trace("Sending direct message...", outgoingMessageData.userId, outgoingMessageData.username, outgoingMessageData.fullName, this.input.value);
					}
					else
					{
						ml.tweetr.sendDirectMessage(this.input.value, outgoingMessageData.username);
					}
				}
			}
			else
			{
				if (ml.testMode)
				{
					trace("Sending regular old message...", this.input.value);
				}
				else
				{
					ml.tweetr.sendTweet(this.input.value);
				}
			}
			ModelLocator.getInstance().currentScreen = Screen.READ_SCREEN;
		}
	}
}