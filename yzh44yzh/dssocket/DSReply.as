package dssocket {
import as2bert.As2Bert;
import as2bert.DecodedData;

import flash.utils.ByteArray;

public class DSReply {
    public var cid : uint = 0;
    public var errorCode : uint = 0;
    public var msg : String = null;
    public var payload : DecodedData = null;

    public function decode(bin : ByteArray) : void {
        var data : DecodedData = As2Bert.decTuple(bin);
        if(data.getString(0) != "reply") throw new Error("Can't decode DSReply from " + bin);

        cid = data.getInt(1);
        msg = data.getString(3);
        payload = data.getDecodedData(4);
        errorCode = data.getInt(5);
    }

    public function get success() : Boolean { return errorCode == 0; }

    public function toString() : String {
        return "DSReply cid:" + cid + " errorCode:" + errorCode + " msg:" + msg + " payload:" + payload;
    }

}

}
