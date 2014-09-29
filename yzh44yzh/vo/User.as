package vo {
	import as2bert.As2Bert;
	import as2bert.DecodedData;
	import as2bert.Utils;

	import flash.utils.ByteArray;

	public class User {

    static public const GUEST : int = 0;
    static public const FACEBOOK : int = 1;
    static public const VKONTAKTE : int = 2;
    static public const ODNOKLASSNIKI : int = 3;
    static public const GAME_CENTER : int = 4;
    static public const BOT : int = 5;
    static public const MM: int = 6;

    public var id : String;
    public var name : String;
    public var chips : uint;
    public var gold : uint;
    public var pro : Boolean;
    public var type : uint;
    public var level : uint;
    public var exp : uint;
    public var avatarUrl : String;

    public var winChips : int = 0;
    public var winGold : Boolean = false;
    public var winSilver : Boolean = false;
    public var winBronze : Boolean = false;

    public function clearWins() : void {
        winChips = -1;
        winGold = false;
        winSilver = false;
        winBronze = false;
    }

    public function encode() : ByteArray {
        return As2Bert.encTuple([
            As2Bert.encAtom("user"),
            As2Bert.encBStr(id),
            As2Bert.encBStr(name),
            As2Bert.encBin(null),
            As2Bert.encChar(pro ? 1 : 0),
            As2Bert.encBStr(avatarUrl)
        ])
    }

    public function decode(data : DecodedData) : User {
        if(data.getString(0) != "user") throw new Error("Can't decode user, invalid data " + data);

        try{
            id = Utils.ba2s(data.getBinary(1));
            name = Utils.ba2s(data.getBinary(2));
            chips = data.getInt(4);
            gold = data.getInt(5);
            pro = data.getChar(6) == 1;
            type = data.getChar(7);
            level = data.getInt(8);
            exp = data.getInt(9);
            avatarUrl = Utils.ba2s(data.getBinary(10));
        }
        catch(e : *) {
            trace("error decoding user", e);
        }
        return this;
    }

    public function toString() : String {
        return "User id:" + id + " name:" + name + " type:" + type +
            " winChips:" + winChips + " winGold:" + winGold + " winSilver:" + winSilver +
            " winBronze:" + winBronze;
    }
}
}
