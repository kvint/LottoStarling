package events {
import flash.events.Event;

import vo.User;

public class ChatEvent extends Event {
    static public const SEND : String = "chatSendEvent";
    static public const RECEIVE : String = "chatReceiveEvent";
    static public const CLEAR : String = "clearChatEvent";

    public var msg : String;
    public var sender : User;

    public function ChatEvent(type : String) {
        super(type, true, false);
    }

    override public function clone() : Event {
        var event : ChatEvent = new ChatEvent(type);
        event.msg = msg;
        event.sender = sender;
        return event;
    }
}
}
