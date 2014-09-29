package vo {
import as2bert.DecodedData;

public class Settings {
    public var bonusAuto1Price : int;
    public var bonusAuto5Price : int;
    public var bonusMissedPrice : int;
    public var bonusHighlightPrice : int;
    public var bonusAddCardPrice : uint;
    public var createTablePrice : uint;

    public var bets : Array = [];
    public var pTableBets : Array = [];

    public var expLine : int;
    public var exp2Lines : int;
    public var expBronze : int;
    public var expSilver : int;
    public var expGold : int;

    public var bonuses : BoughtBonuses;

    public function getBonusPrice(bonusId : int) : int {
        if(bonusId == BoughtBonuses.AUTO_1) return bonusAuto1Price;
        if(bonusId == BoughtBonuses.AUTO_5) return bonusAuto5Price;
        if(bonusId == BoughtBonuses.MISSED) return bonusMissedPrice;
        if(bonusId == BoughtBonuses.HIGHLIGHT) return bonusHighlightPrice;
        if(bonusId == BoughtBonuses.ADD_CARD) return bonusAddCardPrice;
        trace(this, "getBonusPrice, ERR: invalid bonusId", bonusId);
        return 0;
    }

    public function decode(data : DecodedData) : void {
        var bonusPrices : DecodedData = data.getDecodedData(0);
        bonusAuto1Price = bonusPrices.getInt(0);
        bonusAuto5Price = bonusPrices.getInt(1);
        bonusMissedPrice = bonusPrices.getInt(2);
        bonusHighlightPrice = bonusPrices.getInt(3);
        bonusAddCardPrice = data.getInt(2);
        createTablePrice = data.getInt(3);

        var betsData : DecodedData = data.getDecodedData(1);
        bets = [betsData.getInt(0),
                betsData.getInt(1),
                betsData.getInt(2),
                betsData.getInt(3),
                betsData.getInt(4)];

        var exp : DecodedData = data.getDecodedData(5);
        expLine = exp.getInt(0);
        exp2Lines = exp.getInt(1);
        expBronze = exp.getInt(2);
        expSilver = exp.getInt(3);
        expGold = exp.getInt(4);

        bonuses = new BoughtBonuses();
        bonuses.decode(data.getDecodedData(6));

        pTableBets = [];
        for(var i : int = 7; i < data.length; i++) {
            pTableBets.push(data.getInt(i));
        }
        trace(pTableBets);
    }

    public function toString() : String {
        return "Settings prices:" + bonusAuto1Price + "," + bonusAuto5Price + "," + bonusMissedPrice + ","
            + bonusHighlightPrice + "," + bonusAddCardPrice + "," + createTablePrice
            + " bets:" + bets
            + " exp:" + expLine + "," + exp2Lines + "," + expBronze + "," + expSilver + "," + expGold
            + " " + bonuses;
    }
}
}
