package apiTest {
import as2bert.As2Bert;
import common.Utils;
import dssocket.DSReply;
import vo.BoughtBonuses;
import vo.User;
import vo.UserStat;

public class UserInfoApiClient extends BaseClient {

    public function UserInfoApiClient(id : int) {
        super(id);
    }

    protected override function onLogin() : void {
        startTimer();
        super.onLogin();
    }

    protected override function nextQuery() : void {
        userInfo();
    }

    private function userInfo() : void {
        var userId : String = Utils.randBool() ? "unknown_user" : _userId;
        _socket.call("user_info", As2Bert.encBStr(userId),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var user : User = new User()
                    user.decode(reply.payload.getDecodedData(0));
                    var bonuses : BoughtBonuses = new BoughtBonuses();
                    bonuses.decode(reply.payload.getDecodedData(1));
                    var stat : UserStat = new UserStat();
                    stat.decode(reply.payload.getDecodedData(2));
                    addReport(user + " " + stat + " " + bonuses);
                }
                else addError(reply.errorCode);
            });
    }

    public override function toString() : String { return "UserInfoApiClient"; }
}

}
