package dssocket {

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;

public class DSBertSocket extends DSBinSocket {

    private var _nextCid : uint = 1;
    private var _callbacks : Object = {};
    private var _bytesToRead : uint = 0;
    private var _pingTimer : Timer;

    public function DSBertSocket() {
        super();

        _pingTimer = new Timer(10000);
        _pingTimer.addEventListener(TimerEvent.TIMER, ping);
    }

    public override function stop() : void {
        _pingTimer.stop();
        super.stop();
    }

    public function call(action : String, payload : ByteArray = null, callback : Function = null) : void {
        var query : DSCall = new DSCall();
        query.action = action;
        query.payload = payload;

        if(callback != null) {
            query.cid = _nextCid;
            _callbacks[_nextCid] = callback;
            _nextCid++;
        }

        send(query.encode());
    }

    protected override function onData(event : ProgressEvent) : void {
        if(_bytesToRead == 0) {
            var header : int = _socket.readByte();
            if(header == 4 && _socket.bytesAvailable >= 4) {
                _bytesToRead = _socket.readInt();
            }
            else if(header == 2 && _socket.bytesAvailable >= 2) {
                var b1 : int = _socket.readUnsignedByte();
                var b2 : int = _socket.readUnsignedByte();
                _bytesToRead = (b1 << 8) + b2;
            }
            else if(header == 1 && _socket.bytesAvailable >= 1) {
                _bytesToRead = _socket.readUnsignedByte();
            }
            else {
                trace(this, ": invalid header ", header, _socket.bytesAvailable);
                stop();
                reconnect();
                return;
            }
        }

        if(_socket.bytesAvailable < _bytesToRead) return; // wait for more data

        var data : ByteArray = new ByteArray();
        _socket.readBytes(data, 0, _bytesToRead);

        var reply : DSReply = new DSReply();
        reply.decode(data);
        var callback : Function = _callbacks[reply.cid];
        if(callback != null) callback(reply);
        else if(dataCallback != null) dataCallback(reply);

        _bytesToRead = 0;
        if(_socket.bytesAvailable > 0) onData(null);
    }

    protected override function onConnect(event : Event) : void {
        super.onConnect(event);
        _pingTimer.start();
    }

    protected override function onClose(event : Event) : void {
        super.onClose(event);
        _pingTimer.stop();
    }

    private function ping(event : TimerEvent = null) : void {
        call("ping");
    }

    public override function toString() : String { return "DSBertSocket" }
}

}
