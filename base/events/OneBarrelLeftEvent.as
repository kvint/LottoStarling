package events {
import flash.events.Event;

public class OneBarrelLeftEvent extends Event {

    static public const ONE_BARREL_LEFT : String = "oneBarrelLeftEvent";

    public var userId : String;
    public var cardId : int;
    public var number : int;

    public function OneBarrelLeftEvent() {
        super(ONE_BARREL_LEFT, true, false);
    }

    override public function clone() : Event {
        var event : OneBarrelLeftEvent = new OneBarrelLeftEvent();
        event.userId = userId;
        event.cardId = cardId;
        event.number = number;
        return event;
    }
}
}
