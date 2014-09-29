package events {
import flash.events.Event;

import vo.User;
import vo.UserStat;

public class ShowUserStatEvent extends Event {

    static public const SHOW : String = "showUserStatEvent";

    public var stat : UserStat;

    public function ShowUserStatEvent() {
        super(SHOW, true, false);
    }

    override public function clone() : Event {
        var event : ShowUserStatEvent = new ShowUserStatEvent();
        event.stat = stat;
        return event;
    }
}
}
