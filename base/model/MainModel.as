package model {
import controller.MM_DataProvider;
import controller.OkAPI;

import vk.APIConnection;

import vo.PTable;
import vo.Room;
import vo.Settings;
import vo.User;

public class MainModel {

    static public const HOST : String = CONFIG::host;
    static public const PORT : uint = 8090;

    static public const IS_OK : Boolean = CONFIG::is_ok;
    static public const IS_MM : Boolean = CONFIG::is_mm;

    static public var VK : APIConnection;
    static public var OK : OkAPI;
    static public var MM: MM_DataProvider;

    static private var _inst : MainModel = null;

    static public function get inst() : MainModel {
        if(_inst == null) _inst = new MainModel();
        return _inst;
    }

    public var user : User = null;

    public var settings : Settings = null;

    public var currRoom : Room = null;

    public var currTable : PTable = null;

    public var barrels : Array = [];

    public var showWins : Boolean = false;

    public function last5barrels() : Array {
        return barrels.slice(-5);
    }
}
}
