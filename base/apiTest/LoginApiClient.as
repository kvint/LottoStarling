package apiTest {

import as2bert.As2Bert;
import common.Utils;
import dssocket.DSReply;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import vo.Settings;
import vo.User;

public class LoginApiClient extends BaseClient {

    public function LoginApiClient(id : int) {
        super(id);
    }

    protected override function onConnect() : void {
        startTimer();
        deviceInfo();
        super.onConnect();
    }

    protected override function nextQuery() : void {
        var queries : Array = [version, deviceInfo, enter,
            registerUser, vkontakteEnter, facebookEnter];
        var query : Function = Utils.randItem(queries);
        query();
    }

    private function version() : void {
        var versions : Array = ["1.0.0", "1.3.0", "1.3.1",
            "1.3.5", "1.4.0", "1.4.5", "1.5.0", "1.5.5",
            "0.0", "1.0", "4.0", "5.0", "2.5"];
        var version : String = Utils.randItem(versions);

        _socket.call("version", As2Bert.encBStr(version),
            function (reply : DSReply) : void {
                if(reply.success) {
                    var needUpdate : int = reply.payload.getChar(0);
                    var forceUpdate : int = reply.payload.getChar(1);
                    var actualVersion : String = reply.payload.getString(2);
                    addReport("version v:" + version +
                        " nu:" + needUpdate +
                        " fu:" + forceUpdate +
                        " av:" + actualVersion);
                }
                else addError(reply.errorCode);
            });
    }

    private function deviceInfo() : void {
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encAtom("device"),
            As2Bert.encBStr("flash player"), // Os
            As2Bert.encBStr(Capabilities.version), // Version
            As2Bert.encBStr("web"), // DeviceModel
            As2Bert.encBStr("ru"), // Lang
            As2Bert.encBin(null) // Token
        ]);
        _socket.call("device_info", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else addError(reply.errorCode);
            });
    }

    private function enter() : void {
        var userId : String = Utils.randBool() ? _userId : "some_invalid_user_id";
        _socket.call("enter", As2Bert.encBStr(userId),
            function(reply : DSReply) : void {
                if(reply.success) parseEnterData(reply.payload);
                else addError(reply.errorCode);
            });
    }

    private function registerUser() : void {
        _socket.call("register", null,
            function(reply : DSReply) : void {
                if(reply.success) parseEnterData(reply.payload);
                else addError(reply.errorCode);
            });
    }

    private function vkontakteEnter() : void {
        var user : User = new User();
        user.id = "11223344";
        user.name = "VkUser";
        user.avatarUrl = "http://some/avatar.png";
        _socket.call("vkontakte_enter", user.encode(),
            function(reply : DSReply) : void {
                if(reply.success) parseEnterData(reply.payload);
                else addError(reply.errorCode);
            });
    }

    private function facebookEnter() : void {
        var user : User = new User();
        user.id = "55667788";
        user.name = "FbUser";
        user.avatarUrl = "http://some/avatar.png";
        _socket.call("facebook_enter", user.encode(),
            function(reply : DSReply) : void {
                if(reply.success) parseEnterData(reply.payload);
                else addError(reply.errorCode);
            });
    }

    private function parseEnterData(data : Object) : void
    {
        var user : User = new User();
        user.decode(data.getDecodedData(0));

        var bonus : uint = data.getInt(1);

        var settings : Settings = new Settings();
        settings.decode(data.getDecodedData(2));
        addReport(user.toString() + " Bonus:" + bonus + " " + settings);
    }

    public override function toString() : String { return "LoginApiClient"; }
}

}
