package events {
import flash.events.Event;

public class ShopItemsLoadedEvent extends Event {
    static public const LOADED : String = "shopItemsLoadedEvent";

    public var items : Array = [];

    public function ShopItemsLoadedEvent() {
        super(LOADED, true, false);
    }

    override public function clone() : Event {
        var event : ShopItemsLoadedEvent = new ShopItemsLoadedEvent();
        event.items = items.clone();
        return event;
    }
}
}
