package apiTest {
import as2bert.As2Bert;

import dssocket.DSBertSocket;
import dssocket.DSReply;

import flash.events.TimerEvent;

import flash.utils.Timer;

public class BaseClient {

    protected var _userId : String;
    protected var _reports : Object = {};
    protected var _currRoomId : uint = 0;
    protected var _numSuccConnects : int = 0;
    protected var _numDisconnects : int = 0;
    protected var _socket : DSBertSocket;
    protected var _queryTimer : Timer;

    public function BaseClient(id : int) {
        _userId = "testuser_" + id;

        _socket = new DSBertSocket();
        _socket.connectCallback = onConnect;
        _socket.dataCallback = onServerData;
        _socket.closeCallback = onClose;

        _queryTimer = new Timer(2000);
        _queryTimer.addEventListener(TimerEvent.TIMER, onQueryTimer);
    }

    public function get numSuccConnects() : uint { return _numSuccConnects; }

    public function get numDisconnects() : uint { return _numDisconnects; }

    public function start() : void {
        _socket.connect("localhost", 8090);
    }

    public function stop() : void {
        _queryTimer.stop();
        _socket.stop();
    }

    protected function startTimer() : void {
        _queryTimer.start();
    }

    protected function onConnect() : void {
        _numSuccConnects++;

        _socket.call("enter", As2Bert.encBStr(_userId),
            function (reply : DSReply) : void {
                if(reply.success) onLogin();
                else addError(reply.errorCode);
            });
    }

    protected function onClose() : void {
        _numDisconnects++;
    }

    protected function onLogin() : void {
        // do nothing
    }

    private function onQueryTimer(event : TimerEvent) : void {
        nextQuery(); // I don't want to put TimerEvent to nextQuery arguments to simplify its overriding
    }

    protected function nextQuery() : void {
        // do nothing
    }

    protected function onServerData(reply : DSReply) : void {
        addReport("server data " + reply.msg + " " + reply.payload);
    }

    protected function addError(errorCode : int) : void {
        var errorMsg : String = "unknown error";
        switch(errorCode) {
            case 0: errorMsg = "no error"; break;
            case 1: errorMsg = "auth first"; break;
            case 2: errorMsg = "user not found"; break;
            case 3: errorMsg = "room not found"; break;
            case 4: errorMsg = "game not found"; break;
            case 5: errorMsg = "ptable not found"; break;
            case 6: errorMsg = "invalid barrel"; break;
            case 7: errorMsg = "not enough gold"; break;
            case 8: errorMsg = "invalid bonus id"; break;
            case 9: errorMsg = "user has no bonus"; break;
            case 10: errorMsg = "game finished"; break;
            case 11: errorMsg = "invalid data"; break;
            case 12: errorMsg = "unknown query"; break;
        }
        addReport("ERROR : " + errorCode + " " + errorMsg);
    }

    protected function addReport(report : String) : void {
        if(!_reports[report]) _reports[report] = 1;
        else _reports[report]++;
    }

    public function report() : String {
        var res : String = "client " + _userId + "\n disconnects : " + _numDisconnects + "\n";
        for(var report : String in _reports) {
            var num : int = _reports[report];
            res += " " + report + " = " + num + "\n";
        }
        return res;
    }

    public function toString() : String { return "BaseClient"; }
}

}
