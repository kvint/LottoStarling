package controller {

import common.Utils;
import events.PurchaseEvent;
import flash.events.Event;
import flash.system.Security;

import mailru.MailruCall;
import mailru.MailruCallEvent;

import mx.rpc.events.ResultEvent;

import vo.User;

public class MM_DataProvider {

    public var userId : String;

    public var userDataCallback : Function = null;
    public var purchaseSuccessCallback : Function = null;
    public var friendsCallback : Function = null;
    public var appUsersCallback : Function = null;


    public function MM_DataProvider() {

        Security.allowDomain('*');
        // Ставим слушатель на событие готовности API
        MailruCall.addEventListener(Event.COMPLETE, apiReady);
        MailruCall.addEventListener('app.paymentDialogStatus',paymentsLog);
        MailruCall.addEventListener('app.incomingPayment',paymentsLog);
        MailruCall.addEventListener('app.friendsInvitation', eventLog);


    }

    public function init():void{

        // Инициализируем API
        MailruCall.init('lotto', 'd4c60e9625ffdc357f5450e63b44f7ee','714384');
    }

    public function eventLog (event : MailruCallEvent ) : void {
        trace ( "event log " + event.type);
        Utils.traceObj(event.data);
        //mailru.app.events.incomingPayment:
        // 'status': "success" //варианты failed

        //mailru.app.events.friendsInvitation
        // варианты: opened/closed
        //'status': "closed",
        // id приглашенных, только если пользователь действительно кого-то пригласил
        //'data': [123,234,345]
    }

    public function paymentsLog (event : MailruCallEvent ) : void {
        //trace ( "payments log: " + event.type + ">>>>" + event);
        //Utils.traceObj(event.data);

        if(event.type == 'app.incomingPayment'){
            if(event.data.status == 'success'){
                purchaseSuccessCallback();
                trace("Incoming Payment success");
            }
        }

        if(event.type == 'app.paymentDialogStatus'){
            if(event.data.status == 'opened'){
                //purchaseSuccessCallback();
                trace("Payment Dialog is opened");
            }
            if(event.data.status == 'closed'){
                //purchaseSuccessCallback();
                trace("Payment Dialog is closed");
            }

        }


        //mailru.app.events.incomingPayment:
        // 'status': "success" //варианты failed

        //mailru.app.events.friendsInvitation
        // варианты: opened/closed
        //'status': "closed",
        // id приглашенных, только если пользователь действительно кого-то пригласил
        //'data': [123,234,345]
    }

    public function getUserInfo() : void {
        var  userID:String = MailruCall.exec('mailru.session.vid');
        MailruCall.exec('mailru.common.users.getInfo', mainUserLoaded, userID);

        trace('userID: ' + userID);
    }

    public function getFriends() : void {
        MailruCall.exec('mailru.common.friends.getExtended', onFriendsLoaded);
    }

    private function onFriendsLoaded(user_list: Object):void{
        var friends:Array = [];

        for(var i:int = 0; i<user_list.length; i++){
           var user:User = new User();
           user.id = user_list[i].uid;
           user.type = User.MM;
           user.avatarUrl = user_list[i].pic_big;
           user.name =  user_list[i].first_name + " " + user_list[i].last_name;

           friends.push(user);
        }
        if(friends.length>0){
            friendsCallback(friends);
        }

    }




    public function getAppUsers() : void {
        MailruCall.exec('mailru.common.friends.getAppUsers', onAppUsersLoaded);

    }

    private function onAppUsersLoaded(user_list: Object):void{
        var appUsers:Array = [];
        //Utils.traceObj(user_list)
        for(var i:int = 0; i<user_list.length; i++){
            appUsers.push(user_list[i]);
        }
        appUsersCallback(appUsers);
    }

    public function purchase(event : PurchaseEvent) : void {
        trace(this, "purchase", event.itemId, event.itemType, event.amount);

        var productName : String = Utils.formatNum(event.amount);
        if(event.itemId.indexOf("chips") == 0) productName += " фишек";
        else productName += " золота";

        var productDescription : String = productName;

        var code : String = event.itemId;
        var price : int = event.price;

        var params:Object = new Object();

        params.service_id = code;
        params.service_name = productDescription;
        params.mailiki_price = price;

        MailruCall.exec('mailru.app.payments.showDialog', apiCallback, params);

    }

    private function apiCallback(data:Object):void{
        trace("apiCallback ")
        Utils.traceObj(data);
    }

    public function invite() : void {
        MailruCall.exec('mailru.app.friends.invite');
    }

    private function apiReady( event : Event ) : void {
       trace('Mail.ru API ready');
       getUserInfo();
    }



    private function  mainUserLoaded(user_list: Object):void{
        var user:User = new User();
        user.id = user_list[0].uid;
        user.type = User.MM;
        user.avatarUrl = user_list[0].pic_big;
        user.name =  user_list[0].first_name + " " + user_list[0].last_name;
        userDataCallback(user);
//
//        "uid": "15410773191172635989",
//                "first_name": "Евгений",
//                "last_name": "Маслов",
//                "nick": "maslov",
//                "email": "emaslov@mail.ru", // только в users.getInfo и только для внешних сайтов
//                "sex": 0, // 0 - мужчина, 1 - женщина
//                "birthday": "15.02.1980", // дата рождения в формате dd.mm.yyyy
//                "has_pic": 1, // есть ли аватар у пользователя (1 - есть, 0 - нет)
//                "pic": "http://avt.appsmail.ru/mail/emaslov/_avatar",
//            // уменьшенный аватар - размер по большей стороне не более 45px
//                "pic_small": "http://avt.appsmail.ru/mail/emaslov/_avatarsmall",
//            // большой аватар - размер по большей стороне не более 600px
//                "pic_big": "http://avt.appsmail.ru/mail/emaslov/_avatarbig",
//                "link": "http://my.mail.ru/mail/emaslov/",
//                "referer_type": "", // тип реферера (см. ниже)
//                "referer_id": "", // идентификатор реферера (см. ниже)
//                "is_online": 1, // 1 - онлайн, 0 - не онлайн
//                "friends_count": 145, // количество друзей у пользователя
//                "is_verified": 1, //статус верификации пользователя (1 – телефон подтвержден, 0 – не подтвержден)
//                "vip" : 0, // 0 - не вип, 1 - вип
//                "app_installed": 1, // установлено ли у пользователя текущее приложение
//                "location": {
    }


    public function toString() : String { return "MM"; }
}
}
