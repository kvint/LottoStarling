package controller {

import as2bert.As2Bert;
import as2bert.DecodedData;
import common.Errors;
import common.Utils;
import dssocket.DSBertSocket;
import dssocket.DSReply;
import events.*;
import flash.events.Event;
import flash.system.Security;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import mailru.MailruCall;

import model.MainModel;
import spark.components.Application;

import view.BonusPopup;

import view.ConfirmPopup;
import view.InfoPopup;
import vk.APIConnection;
import vk.events.CustomEvent;
import vo.Card;
import vo.PTable;
import vo.Room;
import vo.User;
import vo.UserStat;

public class Main {

    private var _app : Application;
    private var _socket : DSBertSocket = DSBertSocket.instance;
    private var _login : Login = new Login();
    private var _model : MainModel = MainModel.inst;
    private var _lostConnectionPopup : InfoPopup = null;
    private var _lastPurchase : PurchaseEvent = null;
    private var _sound : SoundManager = SoundManager.inst;

    public function Main(app : Application) {
        _app = app;
        _app.addEventListener(PTableEvent.CREATE, createPTable);
        _app.addEventListener(PTableEvent.JOIN, joinPTable);
        _app.addEventListener(PTableEvent.START_GAME, startPTableGame);
        _app.addEventListener(PTableEvent.START_GAME, startPTableGame);
        _app.addEventListener(FindRoomEvent.FIND_ROOM, findRoom);
        _app.addEventListener(EventTypes.CHANGE_ROOM, changeRoom);
        _app.addEventListener(EventTypes.LEAVE_ROOM, leaveRoom);
        _app.addEventListener(SetNumberEvent.SET_NUMBER, setNumber);
        _app.addEventListener(BuyBonusEvent.BUY_BONUS, buyBonus);
        _app.addEventListener(UseBonusEvent.USE_BONUS, useBonus);
        _app.addEventListener(PurchaseEvent.PURCHASE, purchase);
        _app.addEventListener(ExchangeEvent.EXCHANGE, exchange);
        _app.addEventListener(ChatEvent.SEND, sendChatMsg);
    }

    public function start() : void {
        _socket.connectCallback = onConnect;
        _socket.dataCallback = onServerData;
        _socket.closeCallback = onClose;
        _login.loginCallback = onLogin;

        trace(this, "connect to", MainModel.HOST, MainModel.PORT);
        _socket.connect(MainModel.HOST, MainModel.PORT);

        _sound.load(_app.url);
    }

    private function onConnect() : void {
        trace(this, "onConnect");

        _socket.call("version", As2Bert.encBStr("flash"));

        var flashVars: Object = _app.stage.loaderInfo.parameters;

        if(MainModel.IS_OK) {
            MainModel.OK = new OkAPI(flashVars['url']);
            MainModel.OK.userDataCallback = _login.onOkUser;
            MainModel.OK.purchaseSuccessCallback = onOrderSuccess;
            MainModel.OK.getUserInfo();
        }
        else if(MainModel.IS_MM){
            MainModel.MM = new MM_DataProvider();
            MainModel.MM.userDataCallback = _login.onMMUser;
            MainModel.MM.purchaseSuccessCallback = onOrderSuccess;
            MainModel.MM.init();

        }
        else {
            if(!flashVars['api_id']) { // for local testing
                flashVars['api_id'] = 3843009;
                flashVars['viewer_id'] = 197514353;
                flashVars['sid'] = "a23f82e6d752231ccb1266d3ccd945f39c05628c6742b0ddb15338eef882310499ae647cd869cd6bc43d1";
                flashVars['secret'] = "c611060b05";
            }
            MainModel.VK = new APIConnection(flashVars);
            MainModel.VK.addEventListener('onOrderSuccess', onOrderSuccess);
            MainModel.VK.addEventListener('onOrderFail', onOrderFail);
            MainModel.VK.addEventListener('onOrderCancel', onOrderCancel);

            _login.enter(MainModel.VK, flashVars['viewer_id']);
        }

        if(_lostConnectionPopup != null) {
            _app.removeElement(_lostConnectionPopup);
            _lostConnectionPopup = null;
        }
    }


    private function onClose() : void {
        trace(this, "onClose");
        _app.dispatchEvent(new Event(EventTypes.LOST_CONNECTION));
        _app.currentState = "lobby";
        _sound.playLobby();

        if(_lostConnectionPopup == null) {
            _lostConnectionPopup = new InfoPopup();
            _lostConnectionPopup.title = "Проблема";
            _lostConnectionPopup.msg = "Потеряна связь с сервером, восстанавливаем ...";
            _lostConnectionPopup.closeCallback = function(popup : InfoPopup) : void {
                _app.removeElement(popup);
                _lostConnectionPopup = null;
            }
            _app.addElement(_lostConnectionPopup);
        }
    }

    private function onLogin() : void {
        _app.dispatchEvent(new Event(EventTypes.ON_LOGIN));

        if(_model.currRoom != null) {
            trace(this, "restore_game", _model.currRoom.id);
            _model.currRoom.waitingTimeout = 15;
            _app.currentState = "room";
            _app.dispatchEvent(new Event(EventTypes.ON_JOIN_ROOM));
            _socket.call("restore_game", As2Bert.encInt(_model.currRoom.id),
                function(reply : DSReply) : void {
                    if(reply.success) {
                        trace("restore success");
                    }
                    else {
                        _model.currRoom = null;
                        _app.currentState = "lobby";
                        error("restore_game", reply.errorCode);
                    }
                });
        }

        reloadStat();
        loadPTables();
    }

    private function loadPTables() : void {
        _socket.call("get_waiting_ptables", null,
                function(reply : DSReply) : void {
                    var len : int = reply.payload.length;
                    var items : Array = [];
                    for(var i : int = 0; i < len; i++) {
                        var data : DecodedData = reply.payload.getDecodedData(i);
                        var table : PTable = new PTable;
                        table.decode(data.getDecodedData(0));
                        table.decodeOwner(data.getDecodedData(1));
                        table.decodeUsers(data.getDecodedData(2));
                        items.push(table);
                    }
                    var e : PTableEvent = new PTableEvent(PTableEvent.TABLES_LOADED);
                    e.tables = items;
                    _app.dispatchEvent(e);
                });
    }

    private function reloadStat() : void {
        _socket.call("user_stat", As2Bert.encBStr(_model.user.id),
                function(reply : DSReply) : void {
                    if(reply.success) {
                        var e : ShowUserStatEvent = new ShowUserStatEvent();
                        e.stat = new UserStat();
                        e.stat.decode(reply.payload);
                        _app.dispatchEvent(e);
                    }
                });
    }

    private function createPTable(event : PTableEvent) : void {
        trace(this, "createPTable", event.table.isPro, event.table.isQuick);
        _socket.call("create_ptable", event.table.encode(),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var table : PTable = new PTable;
                    table.decode(reply.payload.getDecodedData(0));
                    _model.currTable = table;

                    var room : Room = new Room();
                    room.bet = table.bet;
                    room.id = table.roomId;
                    room.waitingTimeout = 0;
                    _model.currRoom = room;

                    _app.currentState = "room";
                    _app.dispatchEvent(new Event(EventTypes.ON_JOIN_ROOM));
                }
                else error("create_ptable", reply.errorCode);
            });
    }

    private function joinPTable(event : PTableEvent) : void {
        trace(this, "joinPTable", event.table.id);
        _socket.call("join_ptable", As2Bert.encInt(event.table.id),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var roomId : int = reply.payload.getInt(0);
                    event.table.roomId = roomId;
                    _model.currTable = event.table;

                    var room : Room = new Room();
                    room.bet = event.table.bet;
                    room.id = roomId;
                    room.waitingTimeout = 0;
                    _model.currRoom = room;

                    _app.currentState = "room";
                    _app.dispatchEvent(new Event(EventTypes.ON_JOIN_ROOM));
                }
                else error("join_ptable", reply.errorCode);
            });
    }

    private function startPTableGame(event : PTableEvent) : void {
        trace(this, "startPTableGame");
        if(_model.currTable == null) return;

        var data : ByteArray = As2Bert.encTuple([
                As2Bert.encInt(_model.currTable.id),
                As2Bert.encInt(_model.currRoom.id)
        ]);
        _socket.call("start_game_ptable", data,
                function(reply : DSReply) : void {
                    if(reply.success) {
                        // do nothing, wait for server events
                    }
                    else if(reply.errorCode == Errors.ERR_NO_CHIPS ||
                            reply.errorCode == Errors.ERR_NO_GOLD) {
                        _app.dispatchEvent(new Event(EventTypes.SHOW_SHOP, true));
                    }
                    else error("start_game_ptable", reply.errorCode);
                });
    }

    private function findRoom(event : FindRoomEvent) : void {
        trace(this, "findRoom", event.bet);
        _socket.call("find_room", As2Bert.encInt(event.bet),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var room : Room = new Room();
                    room.bet = event.bet;
                    room.id = reply.payload.getInt(0);
                    room.waitingTimeout = reply.payload.getInt(1);
                    _model.currRoom = room;

                    _app.currentState = "room";
                    _app.dispatchEvent(new Event(EventTypes.ON_JOIN_ROOM));
                }
                else error("find_room", reply.errorCode);
            });
    }

    private function changeRoom(event : Event) : void {
        var bet : int = _model.currRoom.bet;
        var roomId : int = _model.currRoom.id;
        _model.currRoom = null;
        _app.dispatchEvent(new ChatEvent(ChatEvent.CLEAR));
        _socket.call("change_room", As2Bert.encInt(roomId),
            function(reply : DSReply) : void {
                if(reply.success) {
                    var room : Room = new Room();
                    room.bet = bet;
                    room.id = reply.payload.getInt(0);
                    room.waitingTimeout = reply.payload.getInt(1);
                    _model.currRoom = room;

                    _app.dispatchEvent(new Event(EventTypes.ON_JOIN_ROOM));
                }
                else error("change_room", reply.errorCode);
            });
    }

    private function leaveRoom(event : Event = null) : void {
        trace(this, "leaveRoom");
        _model.showWins = false;
        _app.dispatchEvent(new ChatEvent(ChatEvent.CLEAR));

        if (_model.currRoom != null) {
            _socket.call("leave_room", As2Bert.encInt(_model.currRoom.id),
                    function (reply : DSReply) : void {
                        if (reply.success) {
                        }
                        else error("leave_room", reply.errorCode);
                    });
            _model.currRoom = null;
        }

        if(_model.currTable != null) {
            _app.currentState = "table_list";
            _model.currTable = null;
        }
        else _app.currentState = "lobby";
        _sound.playLobby();
    }

    private function setNumber(event : SetNumberEvent) : void {
        if(_model.currRoom == null) {
            trace(this, "ERR: setNumber called when no currRoom");
            return;
        }

        _sound.barrelSet();
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encInt(_model.currRoom.id),
            As2Bert.encInt(event.cardId),
            As2Bert.encInt(event.number)
        ]);
        _socket.call("set_number", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                    var exp : int = reply.payload.getInt(0);
                    var level : int = reply.payload.getInt(1);
                    var winGold : int = reply.payload.getInt(2);
                    trace("setNumber exp:" + exp + " level:" + level + " gold:" + winGold);
                }
                else error("set_number", reply.errorCode);
            });
    }

    private function buyBonus(event : BuyBonusEvent) : void {
        trace(this, "buyBonus", event.bonusId);

        _model.user.gold -= _model.settings.getBonusPrice(event.bonusId);
        _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
        _sound.buyBonus();

        var bonusId : int = event.bonusId;
        var apply : int = event.apply ? 1 : 0;
        var roomId : int = _model.currRoom.id;
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encChar(bonusId),
            As2Bert.encChar(apply),
            As2Bert.encInt(roomId)
        ]);
        _socket.call("buy_bonus", data,
            function (reply : DSReply) : void {
                if(reply.success) {
                }
                else error("buy_bonus", reply.errorCode);
            });
    }

    private function useBonus(event : UseBonusEvent) : void {
        trace(this, "useBonus", event.bonusId);
        _sound.buyBonus();
        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encChar(event.bonusId),
            As2Bert.encInt(_model.currRoom.id)
        ]);
        _socket.call("use_bonus", data,
            function(reply : DSReply) : void {
                if(reply.success) {
                }
                else error("use_bonus", reply.errorCode);
            });
    }

    private function purchase(event : PurchaseEvent) : void {
        trace(this, "purchase", event.itemId, event.type, event.amount);
        _lastPurchase = event;
        if(MainModel.HOST != "localhost") {
            if(MainModel.IS_OK) {
                MainModel.OK.purchase(event);
            } else if(MainModel.IS_MM){
                MainModel.MM.purchase(event);
            }
            else MainModel.VK.callMethod("showOrderBox", {type : "item", item : event.itemId});
        }
    }

    private function exchange(event : ExchangeEvent) : void {
        trace(this, "exchange", event.gold);
        _socket.call("exchange_gold", As2Bert.encInt(event.gold),
            function(reply : DSReply) : void {
                if(reply.success) {
                    popup("Сообщение", "Обмен золота на фишки прошел успешно");
                    _model.user.chips += event.gold * 1000;
                    _model.user.gold -= event.gold;
                    _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
                }
                else {
                    popup("Ошибка", "Ошибка при обмене фишек на золото");
                }
            });
    }

    private function sendChatMsg(event : ChatEvent) : void {
        if(_model.currRoom == null) return;

        var data : ByteArray = As2Bert.encTuple([
            As2Bert.encInt(_model.currRoom.id),
            As2Bert.encBStr(event.msg)
        ]);
        _socket.call("chat_msg", data);
    }

    private function onServerData(reply : DSReply) : void {
        switch (reply.msg) {
            case "users":
                if (!checkRoom(reply)) return;
                _model.showWins = false;
                _model.currRoom.users = [];
                var usersData : DecodedData = reply.payload.getDecodedData(1);
                for (var i : int = 0; i < usersData.length; i++) {
                    var user1 : User = new User();
                    user1.decode(usersData.getDecodedData(i));
                    _model.currRoom.users.push(user1);
                }
                _app.dispatchEvent(new Event(EventTypes.UPDATE_USERS));
                break;

            case "on_join_room":
                if (!checkRoom(reply)) return;
                var user2 : User = new User().decode(reply.payload.getDecodedData(1));
                if (_model.currRoom.addUser(user2)) {
                    _app.dispatchEvent(new Event(EventTypes.UPDATE_USERS));
                }
                break;

            case "on_leave_room":
                if (!checkRoom(reply)) return;
                var user3 : User = new User().decode(reply.payload.getDecodedData(1));
                if (_model.currRoom.removeUser(user3.id)) {
                    _app.dispatchEvent(new Event(EventTypes.UPDATE_USERS));
                }
                break;

            case "cards":
                if (!checkRoom(reply, 4)) return;
                _model.barrels = [];
                var event1 : StartGameEvent = new StartGameEvent();
                event1.cards = [Card.init(reply.payload.getBinary(0)),
                    Card.init(reply.payload.getBinary(1)),
                    Card.init(reply.payload.getBinary(2)),
                    Card.init(reply.payload.getBinary(3))];
                _app.dispatchEvent(event1);
                _app.currentState = "game";
                _sound.stopLobby();

                for each(var user4 : User in _model.currRoom.users) user4.clearWins();

                _model.user.chips -= _model.currRoom.bet;
                _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
                break;

            case "barrel":
                if (!checkRoom(reply)) return;
                var barrel : int = reply.payload.getChar(1);
                _model.barrels.push(barrel);
                var event2 : NewBarrelEvent = new NewBarrelEvent();
                event2.barrel = barrel;
                _app.dispatchEvent(event2);
                _sound.barrelShow();
                break;

            case "one_barrel_left":
                if (!checkRoom(reply)) return;
                var event3 : OneBarrelLeftEvent = new OneBarrelLeftEvent();
                event3.userId = Utils.ba2s(reply.payload.getBinary(1));
                event3.cardId = reply.payload.getInt(2);
                event3.number = reply.payload.getInt(3);
                _app.dispatchEvent(event3);
                _sound.oneBarrelLeft();
                break;

            case "bronze_medal":
                if (!checkRoom(reply)) return;
                var event4 : MedalEvent = new MedalEvent(MedalEvent.BRONZE_MEDAL);
                event4.userId = Utils.ba2s(reply.payload.getBinary(1));
                event4.chips = reply.payload.getInt(2);
                _app.dispatchEvent(event4);
                if (_model.user.id == event4.userId) {
                    _model.user.chips += event4.chips;
                    _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
                }
                _sound.winMedal();
                break;

            case "silver_medal":
                if (!checkRoom(reply)) return;
                var event5 : MedalEvent = new MedalEvent(MedalEvent.SILVER_MEDAL);
                event5.userId = Utils.ba2s(reply.payload.getBinary(1));
                event5.chips = reply.payload.getInt(2);
                _app.dispatchEvent(event5);
                if (_model.user.id == event5.userId) {
                    _model.user.chips += event5.chips;
                    _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
                }
                _sound.winMedal();
                break;

            case "end_game":
                if (!checkRoom(reply)) return;

                var winsData : Object = {};
                var dataB : DecodedData = reply.payload.getDecodedData(1);
                winsData.bronzeUserId = Utils.ba2s(dataB.getBinary(0));
                winsData.bronzeChips = dataB.getInt(1);
                var dataS : DecodedData = reply.payload.getDecodedData(2);
                winsData.silverUserId = Utils.ba2s(dataS.getBinary(0));
                winsData.silverChips = dataS.getInt(1);
                var dataG : DecodedData = reply.payload.getDecodedData(3);
                winsData.goldUserId = Utils.ba2s(dataG.getBinary(0));
                winsData.goldChips = dataG.getInt(1);

                _model.showWins = true;
                checkWins(_model.user, winsData);
                for each(var user5 : User in _model.currRoom.users) checkWins(user5, winsData);

                var event7 : MedalEvent = new MedalEvent(MedalEvent.GOLD_MEDAL);
                event7.userId = winsData.goldUserId;
                event7.chips = winsData.goldChips;
                _app.dispatchEvent(event7);
                _app.dispatchEvent(new Event(EventTypes.END_GAME))

                if (_model.user.id == event7.userId) {
                    _model.user.chips += event7.chips;
                    _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
                    _sound.winGame();
                }
                else _sound.gameOver();

                reloadStat();
                setTimeout(function () : void {
                    _app.currentState = "room";
                    _sound.playLobby();
                }, 3000);
                break;

            case "start_time":
                if (!checkRoom(reply)) return;
                _model.currRoom.waitingTimeout = reply.payload.getInt(1);
                _app.currentState = "room";
                _sound.playLobby();
                _app.dispatchEvent(new Event(EventTypes.ON_JOIN_ROOM));
                break;

            case "kick_from_room":
                if (!checkRoom(reply)) return;
                leaveRoom();
                break;

            case "restore_game":
                /*
                 {Cards,
                 Numbers,
                 list_to_binary(lists:reverse(UsedBarrels)),
                 WinnerB,
                 WinnerS,
                 Events,
                 EnabledCards,
                 ds_utils:b2ob(HBonusUsed)}};
                 */
                _app.currentState = "game";
                _sound.stopLobby();
                break;

            case "chat_msg":
                if (!checkRoom(reply)) return;
                var userId : String = Utils.ba2s(reply.payload.getBinary(1));
                var user : User = _model.currRoom.findUser(userId);
                if (user != null) {
                    var msg : String = Utils.ba2s(reply.payload.getBinary(2));
                    var event : ChatEvent = new ChatEvent(ChatEvent.RECEIVE);
                    event.sender = user;
                    event.msg = msg;
                    _app.dispatchEvent(event);
                    _sound.chatMessage();
                }
                break;
            case "new_ptable":
                var table : PTable = new PTable;
                table.decode(reply.payload.getDecodedData(0));
                table.decodeOwner(reply.payload.getDecodedData(1));
                table.decodeUsers(reply.payload.getDecodedData(2));
                var event8 : PTableEvent = new PTableEvent(PTableEvent.NEW_TABLE);
                event8.table = table;
                _app.dispatchEvent(event8);
                break;
            case "hide_ptable":
                var event9 : PTableEvent = new PTableEvent(PTableEvent.HIDE_TABLE);
                event9.tableId = reply.payload.getInt(0);
                _app.dispatchEvent(event9);
                break;
            case "user_join_ptable":
                var event10 : PTableEvent = new PTableEvent(PTableEvent.USER_JOIN);
                event10.tableId = reply.payload.getInt(0);
                event10.user = new User;
                event10.user.decode(reply.payload.getDecodedData(1));
                _app.dispatchEvent(event10);
                break;
            case "user_leave_ptable":
                var event11 : PTableEvent = new PTableEvent(PTableEvent.USER_LEAVE);
                event11.tableId = reply.payload.getInt(0);
                event11.userId = Utils.ba2s(reply.payload.getBinary(1));
                _app.dispatchEvent(event11);
                break;
            case "last_man_standing":
                if (!checkRoom(reply)) return;
                lastManStanding();
                break;
            case "everyday_bonus":
                var bonus : int = reply.payload.getInt(0);
                _model.user.chips += bonus;
                var popup : BonusPopup = new BonusPopup();
                popup.bonus = bonus;
                popup.closeCallback = function(popup : BonusPopup) : void {
                    _app.removeElement(popup);
                }
                _app.addElement(popup);
                break;
            default:
                trace(this, "server data", reply.msg);
        }
    }

    private function lastManStanding() : void {
        var popup : ConfirmPopup = new ConfirmPopup();
        popup.title = "Вы остались одни";
        popup.msg = "Продолжить игру, или забрать банк сейчас?";
        popup.okLabel = "Победа";
        popup.cancelLabel = "Продолжить";
        popup.closeCallback = function(popup : ConfirmPopup, confirm : Boolean) : void {
            if(confirm) {
                _socket.call("last_man_standing", As2Bert.encInt(_model.currRoom.id));
            }
            _app.removeElement(popup);
        }
        _app.addElement(popup);
    }

    private function checkRoom(reply : DSReply, index : int = 0) : Boolean {
        var roomId : int = reply.payload.getInt(index);
        if(_model.currRoom == null) return false;
        return _model.currRoom.id == roomId;
    }

    private function checkWins(user : User, winsData : Object) : void {
        user.winChips = -_model.currRoom.bet;
        if(user.id == winsData.bronzeUserId) {
            user.winBronze = true;
            user.winChips += winsData.bronzeChips;
        }
        if(user.id == winsData.silverUserId) {
            user.winSilver = true;
            user.winChips += winsData.silverChips;
        }
        if(user.id == winsData.goldUserId) {
            user.winGold = true;
            user.winChips += winsData.goldChips;
        }
    }

    private function onOrderSuccess(e : CustomEvent = null) : void {
        trace(this, "onOrderSuccess");

        if(_lastPurchase == null) {
            trace("ERR: last purchase is null");
        }
        else {
            if(_lastPurchase.itemType == "gold") _model.user.gold += _lastPurchase.amount;
            else _model.user.chips += _lastPurchase.amount;
            _app.dispatchEvent(new Event(EventTypes.CHIPS_CHANGED));
            _lastPurchase = null;
        }
    }

    private function onOrderFail(e : CustomEvent) : void {
        trace("onOrderFail", e, e.params, e.data);
    }

    private function onOrderCancel(e : CustomEvent) : void {
        trace("onOrderCancel", e, e.params, e.data);
    }

    private function error(query : String, errorCode : int) : void {
        if(errorCode == 0) return;

        var msgs : Array = Errors.getMsg(errorCode);
        trace(this, query, msgs[0]);
        if(errorCode != 9 && errorCode !=5)
        {
            if(msgs[1] != ""){
             // todo: нужен нормальный обработчик
             popup("Ой, ошибочка", msgs[1]);
            }
        }

    }

    private function popup(title : String, msg : String) : void {
        var popup : InfoPopup = new InfoPopup();
        popup.title = title;
        popup.msg = msg;
        popup.closeCallback = function(popup : InfoPopup) : void {
            _app.removeElement(popup);
        }
        _app.addElement(popup);
    }

    public function toString() : String { return "controller.Main"; }
}
}
