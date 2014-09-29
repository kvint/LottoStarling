package events {
import flash.events.Event;

public class MedalEvent extends Event {
    static public const GOLD_MEDAL : String = "goldMedalEvent";
    static public const SILVER_MEDAL : String = "silverMedalEvent";
    static public const BRONZE_MEDAL : String = "bronzeMedalEvent";

    public var userId : String;
    public var chips : int;

    public function MedalEvent(type : String) {
        super(type, true, false);
    }

    override public function clone() : Event {
        var event : MedalEvent = new MedalEvent(type);
        event.userId = userId;
        event.chips = chips;
        return event;
    }
}
}
