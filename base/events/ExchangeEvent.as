package events {
import flash.events.Event;

public class ExchangeEvent extends Event {
    static public const EXCHANGE : String = "ExchangeEvent";

    public var gold : int;

    public function ExchangeEvent() {
        super(EXCHANGE, true, false);
    }

    override public function clone() : Event {
        var event : ExchangeEvent = new ExchangeEvent();
        event.gold = gold;
        return event;
    }
}
}
