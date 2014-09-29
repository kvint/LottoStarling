/**
 * Created by AlexanderSla on 04.06.2014.
 */
package lotto.mediators {
	import lotto.events.DynamicEvent;
	import lotto.model.AppModel;
	import lotto.model.GameModel;
	import lotto.screens.WelcomeScreen;

	import robotlegs.bender.extensions.starlingViewMap.impl.StarlingMediator;

	import starling.events.Event;

	public class WelcomeMediator extends StarlingMediator{

		[Inject]
		public var model:GameModel;
		[Inject]
		public var app:AppModel;
		private var _view:WelcomeScreen;

		override public function initialize():void {
			super.initialize();
			_view = viewComponent as WelcomeScreen;
			_view.playBtn.addEventListener(Event.TRIGGERED, onPlay)
			_view.chooseBtn.addEventListener(Event.TRIGGERED, onChoose)
		}

		private function onPlay(event:Event):void {
			app.currentState = AppModel.ROOM;
		}
		private function onChoose(event:Event):void {
			app.currentState = AppModel.TABLE_LIST;
		}
	}
}
