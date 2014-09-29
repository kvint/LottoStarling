package events {
import flash.events.Event;

public class UseBonusEvent extends Event {
    static public const USE_BONUS : String = "UseBonusEvent";

    public var bonusId : int;

    public function UseBonusEvent() {
        super(USE_BONUS, true, false);
    }

    override public function clone() : Event {
        var event : UseBonusEvent = new UseBonusEvent();
        event.bonusId = bonusId;
        return event;
    }
}
}
