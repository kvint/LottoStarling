package apiTest {

import as2bert.As2Bert;
import common.Utils;
import dssocket.DSReply;
import flash.utils.ByteArray;
import vo.BoughtBonuses;

public class BonusApiClient extends BaseClient {

    public function BonusApiClient(id : int) {
        super(id);
    }

    protected override function onLogin() : void {
        _socket.call("buy_gold", As2Bert.encInt(100));
        startTimer();
        super.onLogin();
    }

    protected override function nextQuery() : void {
        _socket.call("ping");

        var queries : Array = [loadBonuses, buyBonus, useBonus];
        var query : Function = Utils.randItem(queries);
        query();
    }

    private function loadBonuses() : void {
        _socket.call("load_bonuses", null,
            function(reply : DSReply) : void {
                if(reply.success) {
                    var bonuses : BoughtBonuses = new BoughtBonuses();
                    bonuses.decode(reply.payload);
                    addReport("load_bonuses " + bonuses);
                }
                else addError(reply.errorCode);
            });
    }

    private function buyBonus() : void {
        var bonusId : int = Utils.rand(1, 5);
        var apply : int = Utils.rand(0, 1);
        var roomId : int = Utils.rand(1, 5);
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encChar(bonusId),
            As2Bert.encChar(apply),
            As2Bert.encInt(roomId)
        ]);
        _socket.call("buy_bonus", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else addError(reply.errorCode);
            });
    }

    private function useBonus() : void {
        var bonusId : int = Utils.rand(1, 5);
        var roomId : int = Utils.rand(1, 5);
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encChar(bonusId),
            As2Bert.encInt(roomId)
        ]);
        _socket.call("use_bonus", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else addError(reply.errorCode);
            });
    }

    public override function toString() : String { return "BonusApiClient"; }
}

}
