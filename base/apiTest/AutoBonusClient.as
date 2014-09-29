package apiTest {
import as2bert.As2Bert;

import dssocket.DSReply;

import flash.utils.ByteArray;

public class AutoBonusClient extends BaseClient {

    public function AutoBonusClient(id : int) {
        super(id);
    }

    protected override function onLogin() : void {
        startTimer();
        super.onLogin();
    }

    protected override function nextQuery() : void {
        buy5();
        use1(); use1(); use1(); use1(); use1();
    }

    private function buy5() : void {
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encChar(2),
            As2Bert.encChar(0),
            As2Bert.encInt(0)
        ]);
        _socket.call("buy_bonus", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                    addReport("buy5 ok");
                }
                else addError(reply.errorCode);
            });
    }

    private function use1() : void {
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encChar(1),
            As2Bert.encInt(0)
        ]);
        _socket.call("use_bonus", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                    addReport("use1 ok");
                }
                else addError(reply.errorCode);
            });
    }

    public override function toString() : String { return "AutoBonusClient"; }
}
}
