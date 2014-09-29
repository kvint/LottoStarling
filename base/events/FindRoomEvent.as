package events {
import flash.events.Event;

public class FindRoomEvent extends Event {

    static public const FIND_ROOM : String = "findRoomEvent";

    public var bet : int;

    public function FindRoomEvent() {
        super(FIND_ROOM, true, false);
    }

    override public function clone() : Event {
        var event : FindRoomEvent = new FindRoomEvent();
        event.bet = bet;
        return event;
    }
}
}
