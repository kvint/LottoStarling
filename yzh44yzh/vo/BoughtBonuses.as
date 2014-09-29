package vo {
import as2bert.DecodedData;

public class BoughtBonuses {

    static public const AUTO_1 : int = 1;
    static public const AUTO_5 : int = 2;
    static public const MISSED : int = 3;
    static public const HIGHLIGHT : int = 4;
    static public const ADD_CARD : int = 5;

    public var auto1 : int = 0;
    public var auto5 : int = 0;
    public var missed : int = 0;
    public var highlight : int = 0;
    public var addCard : int = 0;

    public function decode(data : DecodedData) : void {
        for(var i : int = 0; i < data.length; i++) {
            var bonus : DecodedData = data.getDecodedData(i);
            var bonusId : int = bonus.getChar(0);
            var amount : int = bonus.getInt(1);
            switch(bonusId) {
                case 1: auto1 = amount; break;
                case 2: auto5 = amount; break;
                case 3: missed = amount; break;
                case 4: highlight = amount; break;
                case 5: addCard = amount; break;
            }
        }
    }

    public function toString() : String {
        return "BoughtBonuses: a1:" + auto1 + " a5:" + auto5
            + " m:" + missed + " hl:" + highlight + " ac:" + addCard;
    }
}
}
