package events {
import flash.events.Event;

public class StartGameEvent extends Event {

    static public const START_GAME : String = "startGameEvent";

    public var cards : Array;

    public function StartGameEvent() {
        super(START_GAME, true, false);
    }

    override public function clone() : Event {
        var event : StartGameEvent = new StartGameEvent();
        event.cards = cards;
        return event;
    }
}
}
