package controller {
import as2bert.As2Bert;
import as2bert.DecodedData;

import common.Errors;
import dssocket.DSBertSocket;
import dssocket.DSReply;
import flash.net.SharedObject;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import model.MainModel;

import vk.APIConnection;

import vo.Settings;
import vo.User;

public class Login {

    private var _socket : DSBertSocket = DSBertSocket.instance;

    public var loginCallback : Function = null;

    public function enter(vkObj : APIConnection, userId : String) : void {
        trace(this, "enter", CONFIG::user);

        if(CONFIG::user == 0) {
            var params : Object = {
                uids : userId,
                fields : "first_name,last_name,photo_big"
            };

            vkObj.api('getProfiles', params, onUserInfo, onVkRequestFail);
        }
        else if(CONFIG::user == 1) {
            onUserInfo([{uid : '197514353',
                first_name : 'Юрий',
                last_name : 'Жлоба',
                photo_big : 'http://cs416326.vk.me/v416326353/202f/NLCjpgRV-bQ.jpg'}]);
        }
        else if(CONFIG::user == 2) {
            onUserInfo([{uid : '781258757',
                first_name : 'Alexey',
                last_name : 'Loginov',
                photo_big : 'http://cs305112.vk.me/v305112491/843c/ObTuTRkR1ZM.jpg'}]);
        }
        else if(CONFIG::user == 3) {
            onUserInfo([{uid : 'dU2OMg1IPXTUePgbI0Fc',
                first_name : 'Александр',
                last_name : 'Славщик',
                photo_big : 'http://cs308525.vk.me/v308525001/860c/A6O--gRmW_g.jpg'}]);
        }
    }

    private function onUserInfo(data : Object) : void {
        var user : User = new User();
        user.id = data[0].uid;
        user.name = data[0].first_name + " " + data[0].last_name;
        user.avatarUrl = data[0].photo_big;
        user.type = User.VKONTAKTE;
        trace(this, "vkontakte_enter", user, user.avatarUrl);

        _socket.call("vkontakte_enter", user.encode(),
            function(reply : DSReply) : void {
                if(reply.success) onLogin(reply.payload);
                else trace(this, "vkontakte_enter", Errors.getMsg(reply.errorCode));
            });
    }

    public function onOkUser(user : User) : void {
        trace(this, "odnoklassniki_enter", user);
        _socket.call("odnoklassniki_enter", user.encode(),
                function(reply : DSReply) : void {
                    if(reply.success) onLogin(reply.payload);
                    else trace(this, "odnoklassniki_enter", Errors.getMsg(reply.errorCode));
                });
    }

    public function onMMUser(user : User) : void {
        trace(this, "mm_enter", user);
        //todo: replace with mm_enter
        _socket.call("mm_enter", user.encode(),
                function(reply : DSReply) : void {
                    if(reply.success) onLogin(reply.payload);
                    else trace(this, "mm_enter", Errors.getMsg(reply.errorCode));
                });
    }

    private function onVkRequestFail(data : Object) : void {
        trace(this, "onVkRequestFail", data.error_msg);
    }

    public function onLogin(data : DecodedData) : void {
        var user : User = new User();
        user.decode(data.getDecodedData(0));
        MainModel.inst.user = user;
        trace(this, "onLogin", user);

        var so : SharedObject = SharedObject.getLocal("settings");
        so.data.userId = user.id;
        so.flush();

        var settings : Settings = new Settings();
        settings.decode(data.getDecodedData(2));
        MainModel.inst.settings = settings;

        sendDeviceInfo();
        if(loginCallback != null) loginCallback();
    }

    private function sendDeviceInfo() : void {
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encAtom("device"),
            As2Bert.encBStr("flash player"), // Os
            As2Bert.encBStr(Capabilities.version), // Version
            As2Bert.encBStr("web"), // DeviceModel
            As2Bert.encBStr("ru"), // Lang
            As2Bert.encBin(null) // Token
        ]);
        _socket.call("device_info", data);
    }

    public function toString() : String { return "controller.Login"; }
}
}
