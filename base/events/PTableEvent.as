package events {
import flash.events.Event;
import vo.PTable;
import vo.User;

public class PTableEvent extends Event {
    static public const CREATE : String = "createTableEvent";
    static public const TABLES_LOADED : String = "tablesLoadedEvent";
    static public const NEW_TABLE : String = "newTableEvent";
    static public const HIDE_TABLE : String = "hideTableEvent";
    static public const USER_JOIN : String = "userJoinTableEvent";
    static public const USER_LEAVE : String = "userLeaveTableEvent";
    static public const JOIN : String = "joinTableEvent";
    static public const START_GAME : String = "startTableGameEvent";

    public var tables : Array;
    public var tableId : uint;
    public var userId : String;
    public var table : PTable;
    public var user : User;

    public function PTableEvent(type : String) {
        super(type, true, false);
    }
}
}
