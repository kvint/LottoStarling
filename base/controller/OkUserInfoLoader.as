package controller {

import model.MainModel;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import vo.User;

public class OkUserInfoLoader {

    private var _service : HTTPService;
    private var _toLoad : Array;
    private var _loaded : Array;
    private var _callback : Function;

    public function OkUserInfoLoader(serviceUrl : String) {
        _service = new HTTPService();
        _service.method = "GET";
        _service.resultFormat = "e4x";
        _service.url = serviceUrl;
        _service.addEventListener(ResultEvent.RESULT, onResult);
        _service.addEventListener(FaultEvent.FAULT, onError);
    }

    public function load(userIds : Array, callback : Function) : void {
        trace(this, "load", userIds);
        _toLoad = userIds;
        _loaded = [];
        _callback = callback;
        loadNext();
    }

    private function loadNext() : void {
        if(_toLoad.length == 0) {
            _callback(_loaded);
            return;
        }

        var userId : String = _toLoad.shift();

        if (MainModel.HOST != "localhost") {
            _service.send(OkAPI.signRequest({
                method:'users.getInfo',
                emptyPictures:'false',
                uids:userId,
                fields:'uid,first_name,last_name,name,pic_3,url_profile'
            }));
        }
        else {
            var data : String =
            "<ns2:users_getInfo_response xmlns:ns2=\"http://api.forticom.com/1.0/\">" +
                    "<user>" +
                    "<uid>" + userId + "</uid>" +
                    "<first_name>Fr</first_name>" +
                    "<last_name>" + userId.substr(-3, 3) + "</last_name>" +
                    "<name>Fr" + userId.substr(-3, 3) + "</name>" +
                    "<pic_3>http://i514.mycdn.me/getImage?photoId=394130704096&amp;photoType=5</pic_3>" +
                    "<url_profile>http://www.odnoklassniki.ru/profile/238688856032</url_profile>" +
                    "</user>" +
                    "</ns2:users_getInfo_response>";
            var res : XML = new XML(data);
            var e : ResultEvent = new ResultEvent("", false, true, res);
            onResult(e);
        }
    }

    private function onResult(e : ResultEvent) : void {
        var data : XML = e.result as XML;
        var user : User = new User();
        user.id = data.user.uid;
        user.name = data.user.name;
        user.avatarUrl = data.user.pic_3;
        user.type = User.ODNOKLASSNIKI;
        _loaded.push(user);
        loadNext();
    }

    private function onError(e : FaultEvent) : void {
        trace(this, "onError", e);
        loadNext();
    }

    public function toString() : String { return "OkUserInfoLoader"; }
}
}
