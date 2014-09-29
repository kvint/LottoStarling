package dssocket {
import as2bert.As2Bert;

import flash.utils.ByteArray;

public class DSCall {
    public var cid : uint = 0;
    public var action : String = null;
    public var payload : ByteArray = null;

    public function encode() : ByteArray {
        var encPayload : ByteArray = payload;
        if(payload == null) encPayload = As2Bert.encBin(null);

        return As2Bert.encTuple([
            As2Bert.encAtom("call"),
            As2Bert.encInt(cid),
            As2Bert.encString(action),
            encPayload
        ])
    }
}

}
