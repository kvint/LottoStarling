/**
 * Created by AlexanderSla on 04.06.2014.
 */
package lotto.screens {
	import feathers.controls.Button;
	import feathers.controls.Screen;

	public class RoomScreen extends Screen {
		public var backBtn:Button;

		public function RoomScreen() {
			backBtn = new Button();
			backBtn.label = "Back";
			addChild(backBtn);
		}

		override protected function initialize():void {
			super.initialize();
		}
	}
}
