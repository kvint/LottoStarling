/**
 * Created by AlexanderSla on 20.05.2014.
 */
package lotto.model {
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	import lotto.events.DynamicEvent;

	public class AppModel {

		public function AppModel() {
		}

		[Inject]
		public var eventDispatcher:IEventDispatcher;

		private var _currentState:String;

		public function get currentState():String {
			return _currentState;
		}

		public function set currentState(value:String):void {
			if(_currentState != value){
				var from:String = _currentState;
				_currentState = value;
				eventDispatcher.dispatchEvent(new DynamicEvent(DynamicEvent.STATE_CHANGED, from));
			}
		}

		public static const TABLE_LIST:String = "table_list";
		public static const LOBBY:String = "lobby";
		public static const ROOM:String = "room";
		public static const GAME:String = "game";
	}
}
