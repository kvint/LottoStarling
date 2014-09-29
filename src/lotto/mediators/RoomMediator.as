/**
 * Created by AlexanderSla on 26.09.2014.
 */
package lotto.mediators {
	import lotto.events.DynamicEvent;
	import lotto.model.AppModel;
	import lotto.model.GameModel;
	import lotto.screens.RoomScreen;

	import robotlegs.bender.extensions.starlingViewMap.impl.StarlingMediator;

	import starling.events.Event;

	public class RoomMediator extends StarlingMediator{

		[Inject]
		public var app:AppModel;

		[Inject]
		public var model:GameModel;

		private var _view:RoomScreen;

		public function RoomMediator() {
		}

		override public function initialize():void {
			super.initialize();
			_view = viewComponent as RoomScreen;
			_view.backBtn.addEventListener(Event.TRIGGERED, onBackHandler);

			addContextListener(DynamicEvent.ON_ROOM_JOIN, onJoinedRoom);
			addContextListener(DynamicEvent.ON_USERS_UPDATED, onUsersUpdated);
			dispatch(new DynamicEvent(DynamicEvent.ROOM_FIND, {bet:100}));
		}

		private function onUsersUpdated(event:DynamicEvent):void {
			trace(model.currRoom.users);
		}

		private function onJoinedRoom(event:DynamicEvent):void {
			model;
		}

		private function onBackHandler(event:Event):void {
			dispatch(new DynamicEvent(DynamicEvent.ROOM_LEAVE));
		}
	}
}
