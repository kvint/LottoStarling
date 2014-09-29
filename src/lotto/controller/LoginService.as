package lotto.controller {
	import as2bert.As2Bert;
	import as2bert.DecodedData;

	import dssocket.DSBertSocket;
	import dssocket.DSReply;

	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	import lotto.model.Errors;
	import lotto.model.GameModel;

	import vo.Settings;
	import vo.User;

	public class LoginService {

		[Inject]
		public var socket:DSBertSocket;
		[Inject]
		public var model:GameModel;

		public var loginCallback:Function = null;

		public function enter(userId:String):void {
			trace(this, "enter", CONFIG::user);

			/*if(CONFIG::user == 0) {
			 var params : Object = {
			 uids : userId,
			 fields : "first_name,last_name,photo_big"
			 };

			 vkObj.api('getProfiles', params, onUserInfo, onVkRequestFail);
			 }*/
			if (CONFIG::user == 1) {
				onUserInfo([
					{uid: 'dU2OMg1IPXTUePgbI0Fc',
						first_name: 'Александр',
						last_name: 'Славщик',
						photo_big: 'http://cs308525.vk.me/v308525001/860c/A6O--gRmW_g.jpg'}
				]);
			}
			else if (CONFIG::user == 2) {
				onUserInfo([
					{uid: '781258757',
						first_name: 'Alexey',
						last_name: 'Loginov',
						photo_big: 'http://cs305112.vk.me/v305112491/843c/ObTuTRkR1ZM.jpg'}
				]);
			}
			else if (CONFIG::user == 3) {
				onUserInfo([
					{uid: '197514353',
						first_name: 'Юрий',
						last_name: 'Жлоба',
						photo_big: 'http://cs416326.vk.me/v416326353/202f/NLCjpgRV-bQ.jpg'}
				]);
			}
		}

		public function onOkUser(user:User):void {
			trace(this, "odnoklassniki_enter", user);
			socket.call("odnoklassniki_enter", user.encode(),
					function (reply:DSReply):void {
						if (reply.success) onLogin(reply.payload);
						else trace(this, "odnoklassniki_enter", Errors.getMsg(reply.errorCode));
					});
		}

		public function onLogin(data:DecodedData):void {
			var user:User = new User();
			user.decode(data.getDecodedData(0));
			model.user = user;
			trace(this, "onLogin", user);

			var so:SharedObject = SharedObject.getLocal("settings");
			so.data.userId = user.id;
			so.flush();

			var settings:Settings = new Settings();
			settings.decode(data.getDecodedData(2));
			model.settings = settings;

			sendDeviceInfo();
			if (loginCallback != null) loginCallback();
		}

		public function toString():String {
			return "controller.Login";
		}

		private function onUserInfo(data:Object):void {
			var user:User = new User();
			user.id = data[0].uid;
			user.name = data[0].first_name + " " + data[0].last_name;
			user.avatarUrl = data[0].photo_big;
			user.type = User.VKONTAKTE;
			trace(this, "vkontakte_enter", user, user.avatarUrl);

			socket.call("vkontakte_enter", user.encode(),
					function (reply:DSReply):void {
						if (reply.success) onLogin(reply.payload);
						else trace(this, "vkontakte_enter", Errors.getMsg(reply.errorCode));
					});
		}

		private function onVkRequestFail(data:Object):void {
			trace(this, "onVkRequestFail", data.error_msg);
		}

		private function sendDeviceInfo():void {
			var data:ByteArray = As2Bert.encTuple([
				As2Bert.encAtom("device"),
				As2Bert.encBStr("Android"), // Os
				As2Bert.encBStr(Capabilities.version), // Version
				As2Bert.encBStr("web"), // DeviceModel
				As2Bert.encBStr("ru"), // Lang
				As2Bert.encBin(null) // Token
			]);
			socket.call("device_info", data);
		}
	}
}
