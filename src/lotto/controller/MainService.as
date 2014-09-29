package lotto.controller {

	import as2bert.As2Bert;
	import as2bert.DecodedData;
	import as2bert.Utils;

	import dssocket.DSBertSocket;
	import dssocket.DSReply;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import lotto.events.DynamicEvent;
	import lotto.model.AppModel;

	import lotto.model.Errors;

	import lotto.model.GameModel;

	import robotlegs.bender.bundles.mvcs.Mediator;

	import vo.Card;
	import vo.PTable;
	import vo.Room;
	import vo.User;

	public class MainService extends Mediator {

		[Inject]
		public var socket:DSBertSocket;
		[Inject]
		public var loginService:LoginService;
		[Inject]
		public var sounds:SoundService;
		[Inject]
		public var model:GameModel;
		[Inject]
		public var app:AppModel;

		[PostConstruct]
		public function init() {
			addContextListener(DynamicEvent.PTABLE_CREATE, createPTable);
			addContextListener(DynamicEvent.PTABLE_JOIN, joinPTable);
			addContextListener(DynamicEvent.PTABLE_START_GAME, startPTableGame);
			addContextListener(DynamicEvent.ROOM_FIND, findRoom);
			addContextListener(DynamicEvent.ROOM_CHANGE, changeRoom);
			addContextListener(DynamicEvent.ROOM_LEAVE, leaveRoom);
			addContextListener(DynamicEvent.GAME_SET_NUMBER, setNumber);
			addContextListener(DynamicEvent.BUY_BONUS, buyBonus);
			addContextListener(DynamicEvent.USE_BONUS, useBonus);
			addContextListener(DynamicEvent.PURCHASE, purchase);
			addContextListener(DynamicEvent.EXCHANGE, exchange);
			addContextListener(DynamicEvent.CHAT_SEND, sendChatMsg);
		}


		public function start():void {
			socket.connectCallback = onConnect;
			socket.dataCallback = onServerData;
			socket.closeCallback = onClose;
			loginService.loginCallback = onLogin;

			socket.connect("dieselserver.com", 8090);
			app.currentState = AppModel.LOBBY;
//			_sound.load(_app.url);
		}

		public function toString():String {
			return "controller.Main";
		}

		private function onConnect():void {
			trace(this, "onConnect");

			socket.call("version", As2Bert.encBStr("android"));
			loginService.enter(null);

			/*if (_lostConnectionPopup != null) {
				_app.removeElement(_lostConnectionPopup);
				_lostConnectionPopup = null;
			}*/
		}

		private function onClose():void {
			trace(this, "onClose");
			eventDispatcher.dispatchEvent(new DynamicEvent(DynamicEvent.LOST_CONNECTION));
			app.currentState = AppModel.LOBBY;
			sounds.playLobby();

			/*if (_lostConnectionPopup == null) {
				_lostConnectionPopup = new InfoPopup();
				_lostConnectionPopup.title = "Проблема";
				_lostConnectionPopup.msg = "Потеряна связь с сервером, восстанавливаем ...";
				_lostConnectionPopup.closeCallback = function (popup:InfoPopup):void {
					_app.removeElement(popup);
					_lostConnectionPopup = null;
				}
				_app.addElement(_lostConnectionPopup);
			}*/
		}

		private function onLogin():void {
			eventDispatcher.dispatchEvent(new DynamicEvent(DynamicEvent.ON_LOGIN));

			if (model.currRoom != null) {
				trace(this, "restore_game", model.currRoom.id);
				model.currRoom.waitingTimeout = 15;
				app.currentState = AppModel.ROOM;
				dispatch(new DynamicEvent(DynamicEvent.ON_ROOM_JOIN));
				socket.call("restore_game", As2Bert.encInt(model.currRoom.id),
						function (reply:DSReply):void {
							if (reply.success) {
								trace("restore success");
							}
							else {
								model.currRoom = null;
								app.currentState = AppModel.LOBBY;
								error("restore_game", reply.errorCode);
							}
						});
			}

			reloadStat();
			loadPTables();
		}

		private function loadPTables():void {
			socket.call("get_waiting_ptables", null,
					function (reply:DSReply):void {
						var len:int = reply.payload.length;
						var items:Vector.<PTable> = new Vector.<PTable>();
						for (var i:int = 0; i < len; i++) {
							var data:DecodedData = reply.payload.getDecodedData(i);
							var table:PTable = new PTable;
							table.decode(data.getDecodedData(0));
							table.decodeOwner(data.getDecodedData(1));
							table.decodeUsers(data.getDecodedData(2));
							items.push(table);
						}
						model.tables = items;
						dispatch(new DynamicEvent(DynamicEvent.ON_PTABLES_LOAD, items));
					});
		}

		private function reloadStat():void {
			socket.call("user_stat", As2Bert.encBStr(model.user.id),
					function (reply:DSReply):void {
						if (reply.success) {
							//TODO:
							/*var e:ShowUserStatEvent = new ShowUserStatEvent();
							e.stat = new UserStat();
							e.stat.decode(reply.payload);
							dispatch(e);*/
						}
					});
		}

		private function createPTable(event:DynamicEvent):void {
			var userData:Object = event.userData;
			trace(this, "createPTable", userData.table.isPro, userData.table.isQuick);
			socket.call("create_ptable", userData.table.encode(),
					function (reply:DSReply):void {
						if (reply.success) {
							var table:PTable = new PTable;
							table.decode(reply.payload.getDecodedData(0));
							model.currentTable = table;

							var room:Room = new Room();
							room.bet = table.bet;
							room.id = table.roomId;
							room.waitingTimeout = 0;
							model.currRoom = room;

							app.currentState = AppModel.ROOM;
							dispatch(new DynamicEvent(DynamicEvent.ON_ROOM_JOIN));
						}
						else error("create_ptable", reply.errorCode);
					});
		}

		private function joinPTable(event:DynamicEvent):void {
			var table:PTable = event.userData;
			trace(this, "joinPTable", table.id);
			socket.call("join_ptable", As2Bert.encInt(table.id),
					function (reply:DSReply):void {
						if (reply.success) {
							var roomId:int = reply.payload.getInt(0);
							table.roomId = roomId;
							model.currentTable = table;

							var room:Room = new Room();
							room.bet = table.bet;
							room.id = roomId;
							room.waitingTimeout = 0;
							model.currRoom = room;

							app.currentState = AppModel.ROOM;
							dispatch(new DynamicEvent(DynamicEvent.ON_ROOM_JOIN));
						}
						else error("join_ptable", reply.errorCode);
					});
		}

		private function startPTableGame(event:DynamicEvent):void {
			trace(this, "startPTableGame");
			if (model.currentTable == null) return;

			var data:ByteArray = As2Bert.encTuple([
				As2Bert.encInt(model.currentTable.id),
				As2Bert.encInt(model.currRoom.id)
			]);
			socket.call("start_game_ptable", data,
					function (reply:DSReply):void {
						if (reply.success) {
							// do nothing, wait for server events
						}
						else if (reply.errorCode == Errors.ERR_NO_CHIPS ||
								reply.errorCode == Errors.ERR_NO_GOLD) {
							//TODO: show shop
							//dispatch(new Event(EventTypes.SHOW_SHOP, true));
						}
						else error("start_game_ptable", reply.errorCode);
					});
		}

		private function findRoom(event:DynamicEvent):void {
			var userData:Object = event.userData;
			trace(this, "findRoom", userData.bet);
			socket.call("find_room", As2Bert.encInt(userData.bet),
					function (reply:DSReply):void {
						if (reply.success) {
							var room:Room = new Room();
							room.bet = userData.bet;
							room.id = reply.payload.getInt(0);
							room.waitingTimeout = reply.payload.getInt(1);
							model.currRoom = room;
							trace("room found",room);

							app.currentState = AppModel.ROOM;
							dispatch(new DynamicEvent(DynamicEvent.ON_ROOM_JOIN));
						}
						else error("find_room", reply.errorCode);
					});
		}

		private function setNumber(event:DynamicEvent):void {
			if (model.currRoom == null) {
				trace(this, "ERR: setNumber called when no currRoom");
				return;
			}
			var userData:Object = event.userData;
			sounds.barrelSet();
			var data:ByteArray = As2Bert.encTuple([
				As2Bert.encInt(model.currRoom.id),
				As2Bert.encInt(userData.cardId),
				As2Bert.encInt(userData.number)
			]);
			socket.call("set_number", data,
					function (reply:DSReply):void {
						if (reply.success) {
							var exp:int = reply.payload.getInt(0);
							var level:int = reply.payload.getInt(1);
							var winGold:int = reply.payload.getInt(2);
							trace("setNumber exp:" + exp + " level:" + level + " gold:" + winGold);
						}
						else error("set_number", reply.errorCode);
					});
		}

		private function buyBonus(event:DynamicEvent):void {
			var userData:Object = event.userData;
			trace(this, "buyBonus", userData.bonusId);

			model.user.gold -= model.settings.getBonusPrice(userData.bonusId);
			dispatch(new DynamicEvent(DynamicEvent.ON_CHIPS_CHANGED));
			sounds.buyBonus();

			var bonusId:int = userData.bonusId;
			var apply:int = userData.apply ? 1 : 0;
			var roomId:int = model.currRoom.id;
			var data:ByteArray = As2Bert.encTuple([
				As2Bert.encChar(bonusId),
				As2Bert.encChar(apply),
				As2Bert.encInt(roomId)
			]);
			socket.call("buy_bonus", data,
					function (reply:DSReply):void {
						if (reply.success) {
						}
						else error("buy_bonus", reply.errorCode);
					});
		}

		private function useBonus(event:DynamicEvent):void {
			var userData:Object = event.userData;
			trace(this, "useBonus", userData.bonusId);
			sounds.buyBonus();
			var data:ByteArray = As2Bert.encTuple([
				As2Bert.encChar(userData.bonusId),
				As2Bert.encInt(model.currRoom.id)
			]);
			socket.call("use_bonus", data,
					function (reply:DSReply):void {
						if (reply.success) {
						}
						else error("use_bonus", reply.errorCode);
					});
		}

		private function purchase(event:DynamicEvent):void {
			/*trace(this, "purchase", event.itemId, event.type, event.amount);
			_lastPurchase = event;
			if (MainModel.HOST != "localhost") {
				if (MainModel.IS_OK) {
					MainModel.OK.purchase(event);
				} else if (MainModel.IS_MM) {
					MainModel.MM.purchase(event);
				}
				else MainModel.VK.callMethod("showOrderBox", {type: "item", item: event.itemId});
			}*/
		}

		private function exchange(event:DynamicEvent):void {
			//TODO:
			/*trace(this, "exchange", event.gold);
			_socket.call("exchange_gold", As2Bert.encInt(event.gold),
					function (reply:DSReply):void {
						if (reply.success) {
							popup("Сообщение", "Обмен золота на фишки прошел успешно");
							_model.user.chips += event.gold * 1000;
							_model.user.gold -= event.gold;
							dispatch(new Event(EventTypes.CHIPS_CHANGED));
						}
						else {
							popup("Ошибка", "Ошибка при обмене фишек на золото");
						}
					});*/
		}

		private function sendChatMsg(event:DynamicEvent):void {
			if (model.currRoom == null) return;

			var data:ByteArray = As2Bert.encTuple([
				As2Bert.encInt(model.currRoom.id),
				As2Bert.encBStr(event.userData)
			]);
			socket.call("chat_msg", data);
		}

		private function onServerData(reply:DSReply):void {
			switch (reply.msg) {
				case "users":
					if (!checkRoom(reply)) return;
					model.showWins = false;
					model.currRoom.users = [];
					var usersData:DecodedData = reply.payload.getDecodedData(1);
					for (var i:int = 0; i < usersData.length; i++) {
						var user1:User = new User();
						user1.decode(usersData.getDecodedData(i));
						model.currRoom.users.push(user1);
					}
					dispatch(new DynamicEvent(DynamicEvent.ON_USERS_UPDATED));
					break;

				case "on_join_room":
					if (!checkRoom(reply)) return;
					var user2:User = new User().decode(reply.payload.getDecodedData(1));
					if (model.currRoom.addUser(user2)) {
						dispatch(new DynamicEvent(DynamicEvent.ON_USERS_UPDATED));
					}
					break;

				case "on_leave_room":
					if (!checkRoom(reply)) return;
					var user3:User = new User().decode(reply.payload.getDecodedData(1));
					if (model.currRoom.removeUser(user3.id)) {
						dispatch(new DynamicEvent(DynamicEvent.ON_USERS_UPDATED));
					}
					break;

				case "cards":
					if (!checkRoom(reply, 4)) return;
					model.barrels = [];
					var cards:Array = [Card.init(reply.payload.getBinary(0)),
						Card.init(reply.payload.getBinary(1)),
						Card.init(reply.payload.getBinary(2)),
						Card.init(reply.payload.getBinary(3))];
					dispatch(new DynamicEvent(DynamicEvent.GAME_START, cards));
					app.currentState = AppModel.GAME;
					sounds.stopLobby();

					for each(var user4:User in model.currRoom.users) user4.clearWins();

					model.user.chips -= model.currRoom.bet;
					dispatch(new DynamicEvent(DynamicEvent.ON_CHIPS_CHANGED));
					break;

				case "barrel":
					if (!checkRoom(reply)) return;
					var barrel:int = reply.payload.getChar(1);
					model.barrels.push(barrel);
					dispatch(new DynamicEvent(DynamicEvent.GAME_ON_NEW_BARREL, {barrel:barrel}));
					sounds.barrelShow();
					break;

				case "one_barrel_left":
					if (!checkRoom(reply)) return;
					var userData:Object = {};
					userData.userId = Utils.ba2s(reply.payload.getBinary(1));
					userData.cardId = reply.payload.getInt(2);
					userData.number = reply.payload.getInt(3);
					dispatch(new DynamicEvent(DynamicEvent.GAME_ON_ONE_BARREL, userData));
					sounds.oneBarrelLeft();
					break;

				case "bronze_medal":
					if (!checkRoom(reply)) return;
					var userData:Object = {};
					userData.userId = Utils.ba2s(reply.payload.getBinary(1));
					userData.chips = reply.payload.getInt(2);
					dispatch(new DynamicEvent(DynamicEvent.ON_MEDAL_BRONZE, userData));
					if (model.user.id == userData.userId) {
						model.user.chips += userData.chips;
						dispatch(new DynamicEvent(DynamicEvent.ON_CHIPS_CHANGED));
					}
					sounds.winMedal();
					break;

				case "silver_medal":
					if (!checkRoom(reply)) return;
					var userData:Object = {};
					userData.userId = Utils.ba2s(reply.payload.getBinary(1));
					userData.chips = reply.payload.getInt(2);
					dispatch(new DynamicEvent(DynamicEvent.ON_MEDAL_SILVER, userData));
					if (model.user.id == userData.userId) {
						model.user.chips += userData.chips;
						dispatch(new DynamicEvent(DynamicEvent.ON_CHIPS_CHANGED));
					}
					sounds.winMedal();
					break;

				case "end_game":
					if (!checkRoom(reply)) return;

					var winsData:Object = {};
					var dataB:DecodedData = reply.payload.getDecodedData(1);
					winsData.bronzeUserId = Utils.ba2s(dataB.getBinary(0));
					winsData.bronzeChips = dataB.getInt(1);
					var dataS:DecodedData = reply.payload.getDecodedData(2);
					winsData.silverUserId = Utils.ba2s(dataS.getBinary(0));
					winsData.silverChips = dataS.getInt(1);
					var dataG:DecodedData = reply.payload.getDecodedData(3);
					winsData.goldUserId = Utils.ba2s(dataG.getBinary(0));
					winsData.goldChips = dataG.getInt(1);

					model.showWins = true;
					checkWins(model.user, winsData);
					for each(var user5:User in model.currRoom.users) checkWins(user5, winsData);

					var userData:Object = {};
					userData.userId = winsData.goldUserId;
					userData.chips = winsData.goldChips;
					dispatch(new DynamicEvent(DynamicEvent.ON_MEDAL_GOLD, userData));
					dispatch(new DynamicEvent(DynamicEvent.GAME_END));

					if (model.user.id == userData.userId) {
						model.user.chips += userData.chips;
						dispatch(new DynamicEvent(DynamicEvent.ON_CHIPS_CHANGED));
						sounds.winGame();
					}
					else sounds.gameOver();

					reloadStat();
					setTimeout(function ():void {
						app.currentState = AppModel.ROOM;
						sounds.playLobby();
					}, 3000);
					break;

				case "start_time":
					if (!checkRoom(reply)) return;
					model.currRoom.waitingTimeout = reply.payload.getInt(1);
					app.currentState = AppModel.ROOM;
					sounds.playLobby();
					dispatch(new DynamicEvent(DynamicEvent.ON_ROOM_JOIN));
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
					app.currentState = AppModel.GAME;
					sounds.stopLobby();
					break;

				case "chat_msg":
					if (!checkRoom(reply)) return;
					var userId:String = Utils.ba2s(reply.payload.getBinary(1));
					var user:User = model.currRoom.findUser(userId);
					if (user != null) {
						var msg:String = Utils.ba2s(reply.payload.getBinary(2));
						dispatch(new DynamicEvent(DynamicEvent.CHAT_RECEIVE, {sender:user, msg:msg}));
						sounds.chatMessage();
					}
					break;
				case "new_ptable":
					if(model.tables == null) break;
					var table:PTable = new PTable;
					table.decode(reply.payload.getDecodedData(0));
					table.decodeOwner(reply.payload.getDecodedData(1));
					table.decodeUsers(reply.payload.getDecodedData(2));
					model.tables.push(table);
					dispatch(new DynamicEvent(DynamicEvent.ON_PTABLE_NEW, table));
					break;
				case "hide_ptable":
					if(model.tables == null) break;
					var tableId:int = reply.payload.getInt(0);
					for(var i:int = 0; i < model.tables.length; i++){
						var table:PTable = model.tables[i];
						if(table.id == tableId){
							model.tables.splice(i, 1);
							break;
						}
					}
					dispatch(new DynamicEvent(DynamicEvent.ON_PTABLE_HIDE, {tableId:tableId}));
					break;
				case "user_join_ptable":
					var userData:Object = {};
					userData.tableId = reply.payload.getInt(0);
					userData.user = new User;
					userData.user.decode(reply.payload.getDecodedData(1));
					for each(var table:PTable in model.tables){
						if(table.id == userData.tableId){
							if(table.userIds.indexOf(userData.userId) == -1){
								table.userIds.push(userData.userId);
							}
							break;
						}
					}
					dispatch(new DynamicEvent(DynamicEvent.ON_PTABLE_JOIN, userData));
					break;
				case "user_leave_ptable":
					var userData:Object = {};
					userData.tableId = reply.payload.getInt(0);
					userData.userId = Utils.ba2s(reply.payload.getBinary(1));
					for each(var table:PTable in model.tables){
						if(table.id == userData.tableId){
							var indexOfUser:int = table.userIds.indexOf(userData.userId);
							if(indexOfUser != -1){
								table.userIds.splice(indexOfUser, 1);
							}
							break;
						}
					}
					dispatch(new DynamicEvent(DynamicEvent.ON_PTABLE_LEAVE, userData));
					break;
				case "last_man_standing":
					if (!checkRoom(reply)) return;
					lastManStanding();
					break;
				case "everyday_bonus":
					//TODO: handle everyday bonus
					/*var bonus:int = reply.payload.getInt(0);
					_model.user.chips += bonus;
					var popup:BonusPopup = new BonusPopup();
					popup.bonus = bonus;
					popup.closeCallback = function (popup:BonusPopup):void {
						_app.removeElement(popup);
					}
					_app.addElement(popup);*/
					break;
				default:
					trace(this, "server data", reply.msg);
			}
		}

		private function lastManStanding():void {
			/*var popup:ConfirmPopup = new ConfirmPopup();
			popup.title = "Вы остались одни";
			popup.msg = "Продолжить игру, или забрать банк сейчас?";
			popup.okLabel = "Победа";
			popup.cancelLabel = "Продолжить";
			popup.closeCallback = function (popup:ConfirmPopup, confirm:Boolean):void {
				if (confirm) {
					_socket.call("last_man_standing", As2Bert.encInt(_model.currRoom.id));
				}
				_app.removeElement(popup);
			}
			_app.addElement(popup);*/
		}

		private function checkRoom(reply:DSReply, index:int = 0):Boolean {
			var roomId:int = reply.payload.getInt(index);
			if (model.currRoom == null) return false;
			return model.currRoom.id == roomId;
		}

		private function checkWins(user:User, winsData:Object):void {
			user.winChips = -model.currRoom.bet;
			if (user.id == winsData.bronzeUserId) {
				user.winBronze = true;
				user.winChips += winsData.bronzeChips;
			}
			if (user.id == winsData.silverUserId) {
				user.winSilver = true;
				user.winChips += winsData.silverChips;
			}
			if (user.id == winsData.goldUserId) {
				user.winGold = true;
				user.winChips += winsData.goldChips;
			}
		}

		private function error(query:String, errorCode:int):void {
			if (errorCode == 0) return;

			var msgs:Array = Errors.getMsg(errorCode);
			trace(this, query, msgs[0]);
			if (errorCode != 9 && errorCode != 5) {
				if (msgs[1] != "") {
					// todo: нужен нормальный обработчик
					popup("Ой, ошибочка", msgs[1]);
				}
			}

		}

		private function popup(title:String, msg:String):void {
			/*var popup:InfoPopup = new InfoPopup();
			popup.title = title;
			popup.msg = msg;
			popup.closeCallback = function (popup:InfoPopup):void {
				_app.removeElement(popup);
			}
			_app.addElement(popup);*/
		}

		private function changeRoom(event:Event):void {
			var bet:int = model.currRoom.bet;
			var roomId:int = model.currRoom.id;
			model.currRoom = null;
			dispatch(new DynamicEvent(DynamicEvent.CHAT_CLEAR));
			socket.call("change_room", As2Bert.encInt(roomId),
					function (reply:DSReply):void {
						if (reply.success) {
							var room:Room = new Room();
							room.bet = bet;
							room.id = reply.payload.getInt(0);
							room.waitingTimeout = reply.payload.getInt(1);
							model.currRoom = room;

							dispatch(new DynamicEvent(DynamicEvent.ON_ROOM_JOIN));
						}
						else error("change_room", reply.errorCode);
					});
		}

		private function leaveRoom(event:Event = null):void {
			trace(this, "leaveRoom");
			model.showWins = false;
			dispatch(new DynamicEvent(DynamicEvent.CHAT_CLEAR));

			if (model.currRoom != null) {
				socket.call("leave_room", As2Bert.encInt(model.currRoom.id),
						function (reply:DSReply):void {
							if (reply.success) {
							}
							else error("leave_room", reply.errorCode);
						});
				model.currRoom = null;
			}

			if (model.currentTable != null) {
				app.currentState = AppModel.TABLE_LIST;
				model.currentTable = null;
			}
			else app.currentState = AppModel.LOBBY;
			sounds.playLobby();
		}
	}
}
