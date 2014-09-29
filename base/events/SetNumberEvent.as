package events {
import flash.events.Event;

public class SetNumberEvent extends Event {

    static public const SET_NUMBER : String = "setNumberEvent";

    public var cardId : int;
    public var number : int;

    public function SetNumberEvent() {
        super(SET_NUMBER, true, false);
    }

    override public function clone() : Event {
        var event : SetNumberEvent = new SetNumberEvent();
        event.cardId = cardId;
        event.number = number;
        return event;
    }
}
}
