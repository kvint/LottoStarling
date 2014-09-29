/**
 * Created by AlexanderSla on 26.09.2014.
 */
package lotto.screens {
	import feathers.controls.Button;
	import feathers.controls.List;
	import feathers.controls.Screen;
	import feathers.display.Scale9Image;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.textures.Scale9Textures;

	import flash.geom.Rectangle;

	import lotto.Assets;

	import starling.events.Event;

	public class TablesScreen extends Screen {

		public var backBtn:Button;
		public var tablesList:List;
		private var _bg:Scale9Image;

		public function TablesScreen() {
			_bg = new Scale9Image(new Scale9Textures(Assets.get(Assets.RoomBg), new Rectangle(35, 35, 640-35, 960-35)));

			backBtn = new Button();
			backBtn.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
			var backLayout:AnchorLayoutData = new AnchorLayoutData();
			backLayout.top = 20;
			backLayout.left = 30;
			backBtn.layoutData = backLayout;
			tablesList = new List();
			addChild(tablesList);
			addChildAt(_bg, 0);

			var listLayout:AnchorLayoutData = new AnchorLayoutData();
			listLayout.topAnchorDisplayObject = backBtn;
			listLayout.top = 10;
			listLayout.left = 30;
			listLayout.right = 30;
			listLayout.bottom = 150;
			tablesList.layoutData = listLayout;
			tablesList.autoHideBackground = true;

			backBtn.label = "Back to lobby";
			addChild(backBtn);

			layout = new AnchorLayout();
		}
		override protected function screen_addedToStageHandler(event:Event):void {
			super.screen_addedToStageHandler(event);
			_bg.width =  stage.stageWidth;
			_bg.height = stage.stageHeight;
		}
	}
}
