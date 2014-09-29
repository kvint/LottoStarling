package dssocket {
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class DSBinSocket {

		public function DSBinSocket() {
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, onConnect);
			_socket.addEventListener(Event.CLOSE, onClose);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}

		public var connectCallback:Function = null;
		public var closeCallback:Function = null;
		public var dataCallback:Function = null;
		protected var _socket:Socket;
		protected var _host:String;
		protected var _port:int;
		protected var _reconnectTimer:Timer = null;

		public function get connected():Boolean {
			return _socket.connected;
		}

		public function connect(host:String, port:int):void {
			_host = host;
			_port = port;
			_socket.connect(host, port);
		}

		public function stop():void {
			_socket.close();
		}

		public function send(data:ByteArray):void {
			try {
				var length:int = data.length;
				var header:ByteArray = new ByteArray();
				if (length > 0xffff) {
					header.writeByte(4);
					header.writeInt(length);
				}
				else if (length > 0xff) {
					header.writeByte(2);
					header.writeByte(length >> 8);
					header.writeByte(length);
				}
				else {
					header.writeByte(1);
					header.writeByte(length);
				}
				_socket.writeBytes(header);
				_socket.writeBytes(data);
				_socket.flush();
			}
			catch (e:IOError) {
				trace(this, "send error:", e);
			}
		}

		public function toString():String {
			return "DSSocket"
		}

		protected function reconnect():void {
			trace(this, "reconnect in 5 seconds");
			if (!_reconnectTimer) {
				_reconnectTimer = new Timer(5000);
				_reconnectTimer.addEventListener(TimerEvent.TIMER, doReconnect);
			}
			if (!_reconnectTimer.running) _reconnectTimer.start();
		}

		protected function onConnect(event:Event):void {
			if (_reconnectTimer) _reconnectTimer.stop();
			if (connectCallback != null) connectCallback();
		}

		protected function onClose(event:Event):void {
			trace(this, "onClose");
			if (closeCallback != null) closeCallback();
			reconnect();
		}

		protected function onData(event:ProgressEvent):void {
			// override in child class
		}

		protected function onError(event:ErrorEvent):void {
			if (event is IOErrorEvent) {
				trace(this, event.text);
				reconnect();
			}
			else trace(this, "onError:", event);
		}

		protected function doReconnect(event:TimerEvent):void {
			trace(this, "reconnect to", _host, _port);
			_socket.connect(_host, _port);
		};
	}

}
