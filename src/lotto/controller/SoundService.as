package lotto.controller {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;

	public class SoundService {

		public var musicOn:Boolean = true;
		public var soundOn:Boolean = true;
		private var soundPlayer:MovieClip = null;
		private var lobbyMusicOn:Boolean = true;

		public function load(selfUrl:String):void {
			/*var url:String;

			if (MainModel.IS_OK || MainModel.IS_MM) {
				url = "./sound.swf";
			}
			else {
				var protocol:String = (selfUrl != null) ? (selfUrl.split(":")[0]) : "https";
				if (protocol == "https") url = "https://app.vk.com/c6110/u197514353/8520794606afe7.swf";
				else url = "http://app.vk.com/c6110/u197514353/8520794606afe7.swf";
			}

			if (selfUrl.indexOf("http://localhost") == 0) url = "http://localhost/~yurizhloba/sound4.swf";
			trace(this, "load", url, selfUrl);

			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			l.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			l.load(new URLRequest(url));*/
		}

		public function playLobby():void {
			if (soundPlayer != null && musicOn) {
				if (lobbyMusicOn) return;
				lobbyMusicOn = true;
				soundPlayer.playLobby();
			}
		}

		public function stopLobby():void {
			if (soundPlayer != null) {
				lobbyMusicOn = false;
				soundPlayer.stopLobby();
			}
		}

		public function barrelSet():void {
			if (soundPlayer != null && soundOn) soundPlayer.playBarrelMove();
		}

		public function oneBarrelLeft():void {
			if (soundPlayer != null && soundOn) soundPlayer.playBarrelNeeded();
		}

		public function barrelShow():void {
			if (soundPlayer != null && soundOn) soundPlayer.playBarrelShow();
		}

		public function buyBonus():void {
			if (soundPlayer != null && soundOn) soundPlayer.playBuyBonus();
		}

		public function chatMessage():void {
			if (soundPlayer != null && soundOn) soundPlayer.playChatMessage();
		}

		public function chipsWin():void {
			if (soundPlayer != null && soundOn) soundPlayer.playChipsWin();
		}

		public function userMissedBonus():void {
			if (soundPlayer != null && soundOn) soundPlayer.playCoverBonus();
		}

		public function gameOver():void {
			if (soundPlayer != null && soundOn) soundPlayer.playGameOver();
		}

		public function giveUp():void {
			if (soundPlayer != null && soundOn) soundPlayer.playGiveUp();
		}

		public function clickBtn():void {
			if (soundPlayer != null && soundOn) soundPlayer.playPlayBtn();
		}

		public function winGame():void {
			if (soundPlayer != null && soundOn) soundPlayer.playWin();
		}

		public function winMedal():void {
			if (soundPlayer != null && soundOn) soundPlayer.playWinMedal();
		}

		public function toString():String {
			return "SoundManager";
		}

		private function loaded(e:Event):void {
			trace(this, "loaded");
			try {
				soundPlayer = e.target.content as MovieClip;
				if (musicOn) {
					lobbyMusicOn = true;
					soundPlayer.playLobby();
				}
				else lobbyMusicOn = false;
			}
			catch (err:SecurityError) {
				soundPlayer = null;
				trace(this, "can't init soundPlayer", err);
			}
		}

		private function onError(e:ErrorEvent):void {
			trace(this, e);
		}
	}
}
