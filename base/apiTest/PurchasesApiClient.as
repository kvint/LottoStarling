package apiTest {
import as2bert.As2Bert;
import as2bert.DecodedData;

import common.Utils;

import dssocket.DSReply;

import flash.utils.ByteArray;

import vo.ShopItem;

public class PurchasesApiClient extends BaseClient {

    public function PurchasesApiClient(id : int) {
        super(id);
    }

    protected override function onLogin() : void {
        startTimer();
        super.onLogin();
    }

    protected override function nextQuery() : void {
        var queries : Array = [getShopItems, purchase];
        var query : Function = Utils.randItem(queries);
        query();
    }

    private function getShopItems() : void {
        _socket.call("get_shop_items", null,
            function(reply : DSReply) : void {
                if(reply.success) {
                    var report : String = "get_shop_items [";
                    for(var i : int = 0; i < reply.payload.length; i++) {
                        var data : DecodedData = reply.payload.getDecodedData(i);
                        var item : ShopItem = new ShopItem();
                        item.decode(data);
                        report += item.toString() + ", ";
                    }
                    report += "]";
                    addReport(report);
                }
                else addError(reply.errorCode);
            });
    }

    private function purchase() : void {
        var type : int = Utils.rand(0, 1); // 0 -- chips, 1 -- gold
        var total : int = Utils.rand(1, 5);
        var data : ByteArray = As2Bert.encList([
            As2Bert.encChar(type),
            As2Bert.encInt(total),
            As2Bert.encBStr("transaction")
        ]);
        _socket.call("purchase", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else addError(reply.errorCode);
            });
    }

    public override function toString() : String { return "PurchasesApiClient"; }
}
}
