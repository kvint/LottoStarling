package events {
import flash.events.Event;

import vo.User;

public class ShowUserDetailsEvent extends Event {

    static public const SHOW : String = "showUserDetailsEvent";

    public var user : User;

    public function ShowUserDetailsEvent() {
        super(SHOW, true, false);
    }

    override public function clone() : Event {
        var event : ShowUserDetailsEvent = new ShowUserDetailsEvent();
        event.user = user;
        return event;
    }
}
}
