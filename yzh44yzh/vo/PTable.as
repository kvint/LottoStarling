package vo {
	import as2bert.As2Bert;
	import as2bert.DecodedData;
	import as2bert.Utils;

	import flash.utils.ByteArray;

	public class PTable {

		public var id:uint;
		public var ownerId:String;
		public var bet:uint;
		public var password:String;
		public var isPro:Boolean;
		public var isQuick:Boolean;
		public var roomId:uint;

		public var owner:User = null;
		public var userIds:Array = [];

		public function encode():ByteArray {
			return As2Bert.encTuple([
				As2Bert.encInt(bet),
				As2Bert.encChar(isPro ? 1 : 0),
				As2Bert.encChar(isQuick ? 1 : 0),
				As2Bert.encBStr(password)
			])
		}

		public function decode(data:DecodedData):PTable {
			if (data.getString(0) != "ptable") throw new Error("Can't decode ptable, invalid data " + data);

			try {
				id = data.getInt(1);
				ownerId = Utils.ba2s(data.getBinary(2));
				bet = data.getInt(3);
				password = Utils.ba2s(data.getBinary(4));
				isPro = data.getChar(5) == 1;
				isQuick = data.getChar(6) == 1;
				roomId = data.getInt(7);
			}
			catch (e:*) {
				trace("error decoding table", e);
			}
			return this;
		}

		public function decodeOwner(data:DecodedData):void {
			owner = new User;
			owner.decode(data);
		}

		public function decodeUsers(users:DecodedData):void {
			userIds = [];
			for (var j:int = 0; j < users.length; j++) {
				var userData:DecodedData = users.getDecodedData(j);
				var userId:String = Utils.ba2s(userData.getBinary(1));
				userIds.push(userId);
			}
		}

		public function toString():String {
			return "PTable id:" + id + " owner:" + ownerId + " bet:" + bet + " roomId:" + roomId;
		}

	}
}
