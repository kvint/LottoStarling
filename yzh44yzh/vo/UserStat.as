package vo {
import as2bert.DecodedData;

public class UserStat {

    public var totalGames : int = 0;
    public var wins : int = 0;
    public var numGoldMedals : int = 0;
    public var numSilverMedals : int = 0;
    public var numBronzeMedals : int = 0;
    public var winChips : int = 0;

    public function decode(data : DecodedData) : void {
        totalGames = data.getInt(0);
        wins = data.getInt(1);
        numGoldMedals = data.getInt(2);
        numSilverMedals = data.getInt(3);
        numBronzeMedals = data.getInt(4);
        winChips = data.getInt(5);
    }

    public function toString() : String {
        return "UserStat: " + totalGames + " " + wins;
    }
}
}
