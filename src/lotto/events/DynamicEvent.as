/**
 * Created by AlexanderSla on 26.09.2014.
 */
package lotto.events {
	import flash.events.Event;

	public class DynamicEvent extends Event {

		public static const PTABLE_CREATE:String = "ptable_create";
		public static const PTABLE_JOIN:String = "ptable_join";
		public static const PTABLE_START_GAME:String = "ptable_start_game";
		public static const ON_PTABLES_LOAD:String = "ptables_on_load";
		public static const ON_PTABLE_NEW:String = "on_ptable_new";
		public static const ON_PTABLE_HIDE:String = "on_ptable_hide";
		public static const ON_PTABLE_JOIN:String = "on_ptable_join";
		public static const ON_PTABLE_LEAVE:String = "on_ptable_leave";

		public static const ROOM_FIND:String = "room_find";
		public static const ROOM_CHANGE:String = "room_change";
		public static const ROOM_LEAVE:String = "room_leave";
		public static const GAME_SET_NUMBER:String = "game_set_number";
		public static const BUY_BONUS:String = "buy_bonus";
		public static const USE_BONUS:String = "use_bonus";
		public static const PURCHASE:String = "purchase";
		public static const EXCHANGE:String = "exchange";
		public static const CHAT_SEND:String = "send_chat";
		public static const CHAT_RECEIVE:String = "chat_receive";
		public static const CHAT_CLEAR:String = "chat_clear";

		public static const LOST_CONNECTION:String = "lost_connection";
		public static const ON_LOGIN:String = "on_login";
		public static const ON_ROOM_JOIN:String = "on_room_join";
		public static const GAME_START:String = "game_start";
		public static const GAME_END:String = "game_end";
		public static const GAME_ON_ONE_BARREL:String = "game_on_one_barrel";
		public static const GAME_ON_NEW_BARREL:String = "game_on_new_barrel";
		public static const ON_USERS_UPDATED:String = "on_users_updated";
		public static const ON_CHIPS_CHANGED:String = "on_chips_changed";

		public static const ON_MEDAL_GOLD:String = "on_medal_gold";
		public static const ON_MEDAL_SILVER:String = "on_medal_silver";
		public static const ON_MEDAL_BRONZE:String = "on_medal_bronze";

		public static const STATE_CHANGED:String = "onStateChanged";

		private var _userData:*;

		public function DynamicEvent(type:String, userData:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_userData = userData;
		}

		override public function clone():Event {
			return super.clone();
		}

		public function get userData():* {
			return _userData;
		}
	}
}
