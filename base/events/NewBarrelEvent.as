package events {
import flash.events.Event;

public class NewBarrelEvent extends Event {

    static public const NEW_BARREL : String = "newBarrelEvent";

    public var barrel : int;

    public function NewBarrelEvent() {
        super(NEW_BARREL, true, false);
    }

    override public function clone() : Event {
        var event : NewBarrelEvent = new NewBarrelEvent();
        event.barrel = barrel;
        return event;
    }
}
}
