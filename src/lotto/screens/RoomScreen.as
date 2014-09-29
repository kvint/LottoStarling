/**
 * Created by AlexanderSla on 04.06.2014.
 */
package lotto.screens {
	import feathers.controls.Button;
	import feathers.controls.Screen;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class RoomScreen extends Screen {
		public var backBtn:Button;

		public function RoomScreen() {
			backBtn = new Button();
			backBtn.label = "Back";
			backBtn.nameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
			var backLayoutData:AnchorLayoutData = new AnchorLayoutData();
			backLayoutData.top = 20;
			backLayoutData.left = 20;
			backBtn.layoutData = backLayoutData;
			addChild(backBtn);
		}

		override protected function initialize():void {
			super.initialize();
		}
	}
}
