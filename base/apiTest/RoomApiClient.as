package apiTest {
import as2bert.As2Bert;
import as2bert.DecodedData;

import common.Utils;

import dssocket.DSReply;

import vo.User;

public class RoomApiClient extends BaseClient {

    public function RoomApiClient(id : int) {
        super(id);
    }

    protected override function onLogin() : void
    {
        findRoom();
        startTimer();
    }

    protected override function nextQuery() : void {
        var queries : Array = [findRoom, changeRoom, leaveRoom, restoreGame];
        var query : Function = Utils.randItem(queries);
        query();
    }

    private function findRoom() : void {
        _socket.call("find_room", As2Bert.encInt(250),
            function(reply : DSReply) : void {
               if(reply.success) {
                   var roomId : uint = reply.payload.getInt(0);
                   var timeout : uint = reply.payload.getInt(1);
                   _currRoomId = roomId;
                   addReport("find_room: " + roomId + " " + timeout);
               }
               else addError(reply.errorCode);
            });
    }

    private function changeRoom() : void {
        _socket.call("change_room", As2Bert.encInt(_currRoomId),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var roomId : uint = reply.payload.getInt(0);
                    var timeout : uint = reply.payload.getInt(1);
                    _currRoomId = roomId;
                    addReport("change_room: " + roomId + " " + timeout);
                }
                else addError(reply.errorCode);
            });
    }

    private function leaveRoom() : void {
        _socket.call("leave_room", As2Bert.encInt(_currRoomId),
            function(reply : DSReply) : void {
                if(reply.success) {
                    _currRoomId = 0;
                }
                else addError(reply.errorCode);
            });
    }

    private function restoreGame() : void {
        _socket.call("restore_game", As2Bert.encInt(_currRoomId),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var bet : int = reply.payload.getInt(0);
                    addReport("restore_game " + _currRoomId + " " + bet);
                }
                else addError(reply.errorCode);
            });
    }

    protected override function onServerData(reply : DSReply) : void {
        var roomId : int;
        var user : User;
        if(reply.msg == "on_join_room") {
            roomId = reply.payload.getInt(0);
            user = new User();
            user.decode(reply.payload.getDecodedData(1));
            addReport("onJoinRoom " + user);
        }
        else if(reply.msg == "users") {
            roomId = reply.payload.getInt(0);
            var report : String = "onUsers " + roomId + " ["
            var usersData : DecodedData = reply.payload.getDecodedData(1);
            for(var i : int = 0; i < usersData.length; i++) {
                user = new User();
                user.decode(usersData.getDecodedData(i));
                report += user.toString() + ",";
            }
            report += "]";
            addReport(report);
        }
        else addReport("server data " + reply.msg);
    }

    public override function toString() : String { return "RoomApiClient"; }
}

}
