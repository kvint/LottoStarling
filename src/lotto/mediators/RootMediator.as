/**
 * Created by kvint on 20.05.14.
 */
package lotto.mediators {

	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import feathers.themes.MetalWorksMobileTheme;

	import flash.ui.Keyboard;

	import lotto.controller.MainService;
	import lotto.events.DynamicEvent;
	import lotto.model.AppModel;
	import lotto.screens.GameScreen;
	import lotto.screens.RoomScreen;
	import lotto.screens.TablesScreen;
	import lotto.screens.WelcomeScreen;
	import lotto.themes.LottoTheme;
	import lotto.views.RootView;

	import robotlegs.bender.extensions.starlingViewMap.impl.StarlingMediator;

	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.KeyboardEvent;

	public class RootMediator extends StarlingMediator {

		public static const SCREEN_WELCOME:String = "welcomeScreen";
		public static const SCREEN_ROOM:String = "waitingScreen";
		public static const SCREEN_TABLES:String = "tableScreen";
		public static const SCREEN_GAME:String = "gameScreen";

		public function RootMediator() {
			super();
		}

		[Inject]
		public var app:AppModel;
		[Inject]
		public var mainService:MainService;

		private var _view:RootView;
		private var _stage:Stage;
		private var _navigator:ScreenNavigator;
		private var _transitionManager:ScreenSlidingStackTransitionManager;

		override public function destroy():void {
			super.destroy();
		}

		override public function initialize():void {
			super.initialize();
			_stage = (viewComponent as Sprite).stage;
			_view = viewComponent as RootView;
			addContextListener(DynamicEvent.STATE_CHANGED, onStateChanged);

			_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);

			new LottoTheme();

			_navigator = new ScreenNavigator();
			_navigator.addScreen(SCREEN_WELCOME, new ScreenNavigatorItem(WelcomeScreen));
			_navigator.addScreen(SCREEN_TABLES, new ScreenNavigatorItem(TablesScreen));
			_navigator.addScreen(SCREEN_ROOM, new ScreenNavigatorItem(RoomScreen));
			_navigator.addScreen(SCREEN_GAME, new ScreenNavigatorItem(GameScreen));
			_view.addChild(_navigator);

			_transitionManager = new ScreenSlidingStackTransitionManager(_navigator);

			mainService.start();

		}

		private function keyboardHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.BACK){
				switch (app.currentState){
					case AppModel.ROOM:
					case AppModel.TABLE_LIST:
						event.preventDefault();
						event.stopImmediatePropagation();
							app.currentState = AppModel.LOBBY;
						break;
				}
			}
		}

		private function onStateChanged(event:DynamicEvent):void {

			switch (app.currentState) {
				case AppModel.LOBBY:
					_navigator.showScreen(SCREEN_WELCOME);
					break;
				case AppModel.TABLE_LIST:
					_navigator.showScreen(SCREEN_TABLES);
					break;
				case AppModel.GAME:
					_navigator.showScreen(SCREEN_GAME);
					break;
				case AppModel.ROOM:
					_navigator.showScreen(SCREEN_ROOM);
					break;
			}
		}
	}
}
