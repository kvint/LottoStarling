package apiTest {
import as2bert.As2Bert;

import common.Utils;

import dssocket.DSReply;

import flash.utils.ByteArray;

public class GameApiClient extends BaseClient {

    public function GameApiClient(id : int) {
        super(id);
    }

    protected override function onLogin() : void
    {
        _socket.call("buy_chips", As2Bert.encInt(5000));
        if(_currRoomId != 0) joinRoom();
        else findRoom();
        startTimer();
    }

    protected override function nextQuery() : void {
        _socket.call("ping");

        var queries : Array = [setNumber, lastManStanding];
        var query : Function = Utils.randItem(queries);
        query();
    }

    private function joinRoom() : void {
        _socket.call("join_room", As2Bert.encInt(_currRoomId),
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else addError(reply.errorCode);
            });
    }

    private function findRoom() : void {
        _socket.call("find_room", As2Bert.encInt(250),
            function(reply : DSReply) : void {
                if(reply.success) {
                    _currRoomId = reply.payload.getInt(0);
                }
                else addError(reply.errorCode);
            });
    }

    private function setNumber(cardId : int = 0, number : int = 0) : void {
        if(cardId == 0) cardId = Utils.rand(1, 4);
        if(number == 0) number = Utils.rand(1, 100);
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encInt(_currRoomId),
            As2Bert.encInt(cardId),
            As2Bert.encInt(number)
        ]);
        _socket.call("set_number", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                    var exp : int = reply.payload.getInt(0);
                    var level : int = reply.payload.getInt(1);
                    var winGold : int = reply.payload.getInt(2);
                    addReport("setNumber exp:" + exp + " level:" + level + " gold:" + winGold);
                }
                else addError(reply.errorCode);
            });
    }

    private function lastManStanding() : void {
        _socket.call("last_man_standing", As2Bert.encInt(_currRoomId),
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else addError(reply.errorCode);
            });
    }

    protected override function onServerData(reply : DSReply) : void {
        if(reply.msg == "barrel") {
            var roomId : int = reply.payload.getInt(0);
            var barrel : int = reply.payload.getChar(1);
            addReport("barrel in room " + roomId);
            setNumber(1, barrel);
            setNumber(2, barrel);
            setNumber(3, barrel);
            setNumber(4, barrel);
        }
        else addReport("server data " + reply.msg);
    }

    public override function toString() : String { return "GameApiClient"; }
}
}
