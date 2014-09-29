package controller {

import com.api.forticom.ApiCallbackEvent;
import com.api.forticom.ForticomAPI;
import common.Utils;
import events.PurchaseEvent;
import flash.events.Event;
import model.MainModel;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import vk.api.MD5;
import vo.User;

public class OkAPI {

    public var userId : String;

    public var userDataCallback : Function = null;
    public var purchaseSuccessCallback : Function = null;
    public var friendsCallback : Function = null;
    public var appUsersCallback : Function = null;

    static private var _params : Object;
    private var _service : HTTPService;
    private var _loader : OkUserInfoLoader;

    public function OkAPI(url : String) {
        var params : Object = {};
        try {
            var pairs : Array = url.split("?")[1].split("&");
            for each(var pair : String in pairs) {
                var parts : Array = pair.split("=");
                params[parts[0]] = parts[1];
            }
        }
        catch(e:*) {
            trace("can't parse Odnoklassniki params from url", url);
        }

        trace(url);
        trace("OkAPI init with params:");
        var names : Array = ["logged_user_id", "api_server", "application_key",
            "session_secret_key", "session_key", "apiconnection"];
        for each(var name : String in names) {
            trace("    ", name, params[name]);
        }

        userId = params["logged_user_id"];
        _params = params;

        var serviceUrl : String = unescape(params["api_server"]) + "/fb.do?";
        _service = new HTTPService();
        _service.method = "GET";
        _service.resultFormat = "e4x";
        _service.url = serviceUrl;
        _service.addEventListener(ResultEvent.RESULT, onResult);
        _service.addEventListener(FaultEvent.FAULT, onError);

        _loader = new OkUserInfoLoader(serviceUrl);

        ForticomAPI.addEventListener(ForticomAPI.CONNECTED, onForticomConnected);
        ForticomAPI.addEventListener(ApiCallbackEvent.CALL_BACK, onCallback);
        ForticomAPI.connection = params["apiconnection"];
    }

    public function getUserInfo() : void {
        _loader.load([userId], function(users : Array) : void {
            var user : User = users[0];
            if(userDataCallback != null) userDataCallback(user);
        });
    }

    public function getFriends() : void {
        if (MainModel.HOST != "localhost") {
            trace(this, "getFriends");
            _service.send(signRequest({
                method:'friends.get'
            }));
        }
        else {
            var res : XML = <ns2:friends_get_response xmlns:ns2="http://api.forticom.com/1.0/">
                <uid>4866452093112298443</uid>
                <uid>4866452093112298440</uid>
                <uid>4866452093112298441</uid>
                <uid>4866452093112298446</uid>
                <uid>4866452093112298447</uid>
                <uid>4866452093112298444</uid>
                <uid>4866452093112298445</uid>
                <uid>4866452093112298434</uid>
                <uid>4866452093112298435</uid>
                <uid>4866452093112298432</uid>
                <uid>4866452093112298433</uid>
                <uid>4866452093112298438</uid>
                <uid>4866452093112298439</uid>
                <uid>4866452093112298436</uid>
                <uid>4866452093112298437</uid>
                <uid>4866452093112298490</uid>
                <uid>4866452093112298491</uid>
                <uid>4866452093112298488</uid>
                <uid>4866452093112298489</uid>
            </ns2:friends_get_response>
            var e : ResultEvent = new ResultEvent("", false, true, res);
            onResult(e);
        }
    }

    public function getAppUsers() : void {
        if (MainModel.HOST != "localhost") {
            trace(this, "getAppUsers");
            _service.send(signRequest({
                method:'friends.getAppUsers'
            }));
        }
        else {
            var res : XML = <ns2:friends_getAppUsers_response xmlns:ns2="http://api.forticom.com/1.0/">
                <uid>4866452093112298443</uid>
                <uid>4866452093112298440</uid>
                <uid>4866452093112298441</uid>
                <uid>4866452093112298446</uid>
                <uid>4866452093112298447</uid>
                <uid>4866452093112298444</uid>
                <uid>4866452093112298445</uid>
                <uid>4866452093112298434</uid>
                <uid>4866452093112298435</uid>
                <uid>4866452093112298436</uid>
            </ns2:friends_getAppUsers_response>
            var e : ResultEvent = new ResultEvent("", false, true, res);
            onResult(e);
        }
    }

    public function purchase(event : PurchaseEvent) : void {
        trace(this, "purchase", event.itemId, event.itemType, event.amount);

        var productName : String = Utils.formatNum(event.amount);
        if(event.itemId.indexOf("chips") == 0) productName += " фишек";
        else productName += " золота";

        var productDescription : String = productName;

        var code : String = event.itemId;
        var price : int = event.price;
        ForticomAPI.showPayment(productName, productDescription, code, price, "", "", 'ok', 'true');
    }

    public function invite() : void {
        ForticomAPI.showInvite();
    }

    protected function onForticomConnected(event : Event) : void {
        trace(this, "Forticom connected");
    }

    protected function onCallback(event : ApiCallbackEvent) : void {
        trace(this, "onCallback", event.method, event.result, event.data);
        /*
         OkAPI purchase chips1 red 20000
         Sending showPayment (name chips1,description red 20000,just some code,3,,,ok,true)
         OkAPI onCallback showPayment ok {"amount" : "10"}
         */
        if(event.method == "showPayment" && event.result == "ok") {
            if(purchaseSuccessCallback != null) purchaseSuccessCallback();
        }
    }

    private function onResult(e : ResultEvent) : void {
        var data : XML = e.result as XML;
        // trace(this, "onResult", data);
        if(isReplyTo("friends_get", data)) {
            var friendIds : Array = [];
            for(var j : int = 0; j < data.children().length(); j++)
                friendIds.push(data.uid[j]);
            friendIds.sort();
            _loader.load(friendIds, friendsCallback);
        }
        else if(isReplyTo("friends_getAppUsers", data)) {
            var appUsers : Array = [];
            for(var i : int = 0; i < data.children().length(); i++)
                appUsers.push(data.uid[i]);
            if(appUsersCallback != null) appUsersCallback(appUsers);
        }
    }

    private function isReplyTo(query : String, data : XML) : Boolean {
        return (data.name() as QName).localName == query + "_response";
    }

    private function onError(e : FaultEvent) : void {
        trace(this, "onError", e);
    }

    static public function signRequest(data : Object, exeption : Boolean = false, format : String = "XML") : Object {
        data["format"] = format;
        data["application_key"] = _params["application_key"];
        if (data['uid'] == undefined || exeption)
            data["session_key"] = _params["session_key"];

        var sig : String = '';
        var keys : Array = [], key : String;
        for (key in data) { keys.push(key); }
        keys.sort();
        var i: int = 0, l : int = keys.length;
        for (i; i < l; i++)
        {
            sig += keys[i] + "=" + data[keys[i]];
        }
        sig += _params["session_secret_key"];

        data["sig"] = MD5.encrypt(sig).toLowerCase();
        return data;
    }

    public function toString() : String { return "OkAPI"; }
}
}
