/**
 * Created by AlexanderSla on 26.09.2014.
 */
package lotto.mediators {
	import feathers.data.ListCollection;

	import lotto.events.DynamicEvent;
	import lotto.model.AppModel;
	import lotto.model.GameModel;
	import lotto.screens.TablesScreen;

	import robotlegs.bender.extensions.starlingViewMap.impl.StarlingMediator;

	import starling.display.Image;
	import starling.display.Quad;

	import starling.events.Event;

	import vo.PTable;
	import vo.User;

	public class TablesMediator extends StarlingMediator {


		private static const ASCENDING:int = 1;
		private static const DESCENDING:int = -1;
		private static const SAME:int = 0;

		[Inject]
		public var app:AppModel;
		[Inject]
		public var model:GameModel;

		private var _view:TablesScreen;

		override public function initialize():void {
			_view = viewComponent as TablesScreen;
			addContextListener(DynamicEvent.ON_PTABLES_LOAD, onPtablesLoaded);
			addContextListener(DynamicEvent.ON_PTABLE_HIDE, onPtableHide);
			addContextListener(DynamicEvent.ON_PTABLE_NEW, onPtableNew);
			addContextListener(DynamicEvent.ON_PTABLE_JOIN, onPtableJoin);
			_view.backBtn.addEventListener(Event.TRIGGERED, onBackHandler);
			_view.tablesList.addEventListener(Event.CHANGE, list_changeHandler);
			_view.tablesList.itemRendererType = PTableListRenderer;

			reloadList();
		}

		private function reloadList():void {
			var tables:Vector.<PTable> = model.tables.sort(function(table1:PTable, table2:PTable):int{

				//by availability
				if(table1.bet < model.user.chips && table2.bet > model.user.chips){
					return ASCENDING;
				}else if (table1.bet > model.user.chips && table2.bet < model.user.chips){
					return DESCENDING;
				}
				//by users count
				if(table1.userIds.length > table2.userIds.length){
					return ASCENDING;
				}else if(table1.userIds.length < table2.userIds.length){
					return DESCENDING;
				}
				//by bet (grathers first)
				if(table1.bet > table2.bet){
					return ASCENDING;
				}else{
					return DESCENDING;
				}
				return SAME;
			});
			_view.tablesList.dataProvider = new ListCollection(tables);
		}

		private function onPtableNew(event:DynamicEvent):void {
			reloadList();
		}

		private function list_changeHandler(event:Event):void {
			//TODO: handle selection
			var selectedPtable:PTable = _view.tablesList.selectedItem as PTable;
			if(selectedPtable) dispatch(new DynamicEvent(DynamicEvent.PTABLE_JOIN, selectedPtable));
		}

		private function onPtablesLoaded(event:DynamicEvent):void {
			reloadList();
		}

		private function onPtableJoin(event:DynamicEvent):void {
			var userData:Object = event.userData;
			var user:User = userData.user;
			var tableId:int = userData.tableId;

			trace("User", user.name, "joined table", tableId);

			reloadList();
		}

		private function onPtableHide(event:DynamicEvent):void {
			reloadList();
		}

		private function onBackHandler(event:Event):void {
			app.currentState = AppModel.LOBBY;
		}

		override public function destroy():void {
			_view.tablesList.removeEventListener(Event.CHANGE, list_changeHandler);
			_view.backBtn.removeEventListener(Event.TRIGGERED, onBackHandler);
			super.destroy();
		}
	}
}

import feathers.controls.ImageLoader;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.text.engine.ElementFormat;

import lotto.Assets;

import lotto.Assets;
import lotto.themes.LottoTheme;

import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.AssetManager;

import vo.PTable;

class PTableListRenderer extends DefaultListItemRenderer {

	private var _avatarBg:Image;
	private var _avatar:ImageLoader;
	private var _ptable:PTable;
	private var _users:RatingView;
	private var _bet:Label;
	private var _name:Label;
	private var _layoutGroup:LayoutGroup;

	override protected function initialize():void {
		super.initialize();
		_avatarBg = new Image(Assets.get(Assets.AvatarTable));
		_avatar = new ImageLoader();
		_avatar.setSize(63,63);
		_avatar.x = 12;
		_avatar.y = 13;
		_layoutGroup = new LayoutGroup();
		_bet = new Label();
		_name = new Label();
		_users = new RatingView(Assets.get(Assets.TablePerson), Assets.get(Assets.TablePersonH));
		applyTheme();

		_layoutGroup.addChild(_avatarBg);
		_layoutGroup.addChild(_avatar);
		_layoutGroup.addChild(_name);
		_layoutGroup.addChild(_users);
		_layoutGroup.addChild(_bet);

		_users.x = _avatarBg.x + _avatarBg.width;
		_users.y = _avatarBg.y + _avatarBg.height - _users.height;

		addChild(_layoutGroup);
		_layoutGroup.layout = new AnchorLayout();
		var nameLayout:AnchorLayoutData = new AnchorLayoutData();
		nameLayout.left = 10;
		nameLayout.leftAnchorDisplayObject = _avatarBg;
		_name.layoutData = nameLayout;

		var betLayout:AnchorLayoutData = new AnchorLayoutData();
		betLayout.verticalCenter = 0;
		betLayout.right = 10;
		_bet.layoutData = betLayout;

		defaultLabelProperties.elementFormat = new ElementFormat(null, 28);
		this.labelFunction = function(data:Object):String {
			return "";
		}
		this.height = 120;
		var background:Quad = new Quad(10,10);
		background.alpha = 0;
		this.defaultSkin = background;
	}

	private function applyTheme():void {
		_bet.nameList.add(LottoTheme.LOTTO_BET_LABEL);
		_name.nameList.add("dark-label");
	}

	override protected function layoutContent():void {
		super.layoutContent();
		_layoutGroup.width = this.actualWidth;
		_layoutGroup.height = this.actualHeight;

	}

	override public function set data(value:Object):void {
		super.data = value;
		if(_data) {
			_ptable = _data as PTable;
			_bet.text = _ptable.bet.toString();
			_name.text = _ptable.owner.name;
			_users.fill = _ptable.userIds.length;
			_avatar.source = _ptable.owner.avatarUrl;
		}
	}
}

class RatingView extends Sprite {

	private var _texture1:Texture;
	private var _texture2:Texture;

	private var _count:int;
	private var _fill:int;
	private var _movieClips:Vector.<MovieClip>;

	public function RatingView(texture1:Texture, texture2:Texture, count:int = 5){
		_texture1 = texture1;
		_texture2 = texture2;
		_count = count;

		createView();
		this.fill = 0;
	}

	private function createView():void {
		var x:Number = 0;
		_movieClips = new Vector.<MovieClip>();
		for (var i:int = 0; i < _count; i++) {
			var mc:MovieClip = new MovieClip(Vector.<Texture>([_texture1, _texture2]));
			mc.x = x;
			x += mc.width;
			addChild(mc);
			_movieClips.push(mc);
		}
	}

	public function get fill():int {
		return _fill;
	}

	public function set fill(value:int):void {
		_fill = value;
		for (var i:int = 0; i < _movieClips.length; i++) {
			var mc:MovieClip = _movieClips[i];
			mc.currentFrame = i >= _fill ? 1 : 0;
		}
	}

	override public function dispose():void {
		_movieClips = null;
		_texture1 = null;
		_texture2 = null;
		super.dispose();
	}
}