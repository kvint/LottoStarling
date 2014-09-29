/**
 * Created by AlexanderSla on 04.06.2014.
 */
package lotto.screens {
	import feathers.controls.Button;
	import feathers.controls.Screen;
	import feathers.display.Scale9Image;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.textures.Scale9Textures;

	import flash.geom.Rectangle;

	import lotto.Assets;
	import lotto.model.GameModel;

	import starling.events.Event;

	public class WelcomeScreen extends Screen {

		public var _topPanel:Scale9Image;
		public var playBtn:Button;
		public var chooseBtn:Button;

		public function WelcomeScreen() {
			super();
			_topPanel = new Scale9Image(new Scale9Textures(Assets.get(Assets.TopPanel), new Rectangle(6, 4, 640-10, 189-4)));
			playBtn = new Button();
			playBtn.label = "Play";
			chooseBtn = new Button();
			chooseBtn.label = "Choose table";

			addChild(_topPanel);
			addChild(playBtn);
			addChild(chooseBtn);

			var layoutData1:AnchorLayoutData = new AnchorLayoutData();
			layoutData1.horizontalCenter = 0;
			layoutData1.percentWidth = 30;
			layoutData1.bottom = 10;
			layoutData1.bottomAnchorDisplayObject = chooseBtn;
			playBtn.layoutData = layoutData1;

			var layoutData2:AnchorLayoutData = new AnchorLayoutData();
			layoutData2.bottom = 100;
			layoutData2.percentWidth = 30;
			layoutData2.horizontalCenter = 0;
			chooseBtn.layoutData = layoutData2;

			layout = new AnchorLayout();
		}

		override protected function screen_addedToStageHandler(event:Event):void {
			super.screen_addedToStageHandler(event);
			_topPanel.width =  stage.stageWidth;
			_topPanel.height = stage.stageHeight * 0.3;
		}
	}
}
