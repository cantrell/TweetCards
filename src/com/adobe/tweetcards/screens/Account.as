package com.adobe.tweetcards.screens
{
	import com.adobe.tweetcards.components.SimpleButton;
	import com.adobe.tweetcards.components.SimpleInput;
	import com.adobe.tweetcards.components.SimpleLabel;
	import com.adobe.tweetcards.components.SimpleSkinnedButton;
	import com.adobe.tweetcards.model.ModelLocator;
	
	import flash.display.Bitmap;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	public class Account extends Screen
	{
		
		private const FORM_X:uint = 50;
		private const FORM_Y:uint = 75;
		
		private var usernameInput:SimpleInput;
		private var passwordInput:SimpleInput;
		private var saveButton:SimpleSkinnedButton;
		private var clearButton:SimpleButton;
		private var glow:GlowFilter;
		
		public function Account()
		{
			super();
			this.draw();
		}
		
		public override function onShow():void
		{
			this.saveButton.removeGlow();
		}
		
		protected override function draw():void
		{
			super.draw();

			var ml:ModelLocator = ModelLocator.getInstance();
			
			var title:Bitmap = new ml.titleCard();
			this.centerHorizontally(title);
			title.y = 0;
			this.addChild(title);
			
			this.glow = new GlowFilter(0xFF0000);

			// username input
			this.usernameInput = new SimpleInput(150, 27);
			this.usernameInput.x = 10;
			this.usernameInput.y = 139;
			this.addChild(this.usernameInput);
			this.usernameInput.textField.addEventListener(FocusEvent.FOCUS_IN, onFocus);

			// username label
			var usernameLabel:SimpleLabel = new SimpleLabel("Twitter Username", "bold", 0xcccccc, "_sans", 18);
			usernameLabel.x = 164;
			usernameLabel.y = usernameInput.y + 21;
			this.addChild(usernameLabel);

			// password input
			this.passwordInput = new SimpleInput(150, 27, false, true);
			this.passwordInput.x = usernameInput.x;
			this.passwordInput.y = usernameInput.y + 36;
			this.addChild(this.passwordInput);
			this.passwordInput.textField.addEventListener(FocusEvent.FOCUS_IN, onFocus);

			// password label
			var passwordLabel:SimpleLabel = new SimpleLabel("Twitter Password", "bold", 0xcccccc, "_sans", 18);
			passwordLabel.x = usernameLabel.x;
			passwordLabel.y = passwordInput.y + 21;
			this.addChild(passwordLabel);
			
			// save button
			this.saveButton = new SimpleSkinnedButton(ml.signInButtonSkin);
			this.centerHorizontally(this.saveButton);
			this.saveButton.y = this.passwordInput.y + 32;
			this.saveButton.addEventListener(MouseEvent.MOUSE_DOWN, onSaveAccountInfo);
			this.addChild(this.saveButton);
			
			// populate
			var credentials:Object = ModelLocator.getInstance().credentials;
			if (credentials)
			{
				this.usernameInput.textField.text = credentials.username;
				this.passwordInput.textField.text = credentials.password;
			}
		}
		
		private function onFocus(e:FocusEvent):void
		{
			var tf:TextField = e.target as TextField;
			tf.parent.filters = null;
		}
		
		private function onSaveAccountInfo(e:MouseEvent):void
		{
			this.saveButton.addGlow();
			var username:String = this.usernameInput.value;
			var password:String = this.passwordInput.value;
			var errors:Boolean = false;
			if (username.length == 0)
			{
				this.usernameInput.filters = [this.glow];
				errors = true;
			}
			if (password.length == 0)
			{
				this.passwordInput.filters = [this.glow];
				errors = true;
			}
			
			if (errors) return;
			
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.testMode = (this.usernameInput.value == "test" && this.passwordInput.value == "test") ? true : false;
			ml.credentials = {"username":this.usernameInput.value, "password":this.passwordInput.value};
			ml.currentScreen = Screen.READ_SCREEN;
		}
		
		private function onClearForm(e:MouseEvent):void
		{
			this.usernameInput.textField.text = "";
			this.passwordInput.textField.text = "";
		}
	}
}