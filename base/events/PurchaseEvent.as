package events {
import flash.events.Event;

public class PurchaseEvent extends Event {
    static public const PURCHASE : String = "PurchaseEvent";

    public var itemId : String;
    public var itemType : String;
    public var amount : int;
    public var price : int;

    public function PurchaseEvent() {
        super(PURCHASE, true, false);
    }

    override public function clone() : Event {
        var event : PurchaseEvent = new PurchaseEvent();
        event.itemId = itemId;
        return event;
    }
}
}
