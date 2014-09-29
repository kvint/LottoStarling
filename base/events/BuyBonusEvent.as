package events {
import flash.events.Event;

public class BuyBonusEvent extends Event {
    static public const BUY_BONUS : String = "buyBonusEvent";

    public var bonusId : int;
    public var apply : Boolean;

    public function BuyBonusEvent() {
        super(BUY_BONUS, true, false);
    }

    override public function clone() : Event {
        var event : BuyBonusEvent = new BuyBonusEvent();
        event.bonusId = bonusId;
        event.apply = apply;
        return event;
    }
}
}
