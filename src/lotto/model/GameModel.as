/**
 * Created by AlexanderSla on 26.09.2014.
 */
package lotto.model {
	import vo.PTable;
	import vo.Room;
	import vo.Settings;
	import vo.User;

	public class GameModel {

		public var user : User = null;

		public var settings : Settings = null;

		public var currRoom : Room = null;

		public var currentTable : PTable = null;

		public var barrels : Array = [];

		public var showWins : Boolean = false;

		public var tables:Vector.<PTable>;

		public function last5barrels() : Array {
			return barrels.slice(-5);
		}
	}
}
