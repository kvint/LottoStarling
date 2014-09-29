package vo {
import flash.utils.ByteArray;

public class Card {

    static public function init(bin : ByteArray) : Card {
        var card : Card = new Card();
        card.decode(bin);
        return card;
    }

    public var cells : Array;

    public function decode(bin : ByteArray) : void {
        cells = [];
        for(var i : int = 0; i < bin.length; i++) cells.push(bin[i]);
    }

    public function initDefault() : void {
        cells = [6, 00, 28, 00, 47, 00, 63, 00, 89,
                 0, 00, 20, 34, 00, 53, 00, 70, 86,
                 0, 11, 00, 32, 45, 51, 00, 77, 00];
    }
}
}
